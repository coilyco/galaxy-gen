#!/usr/bin/env bash
set -euo pipefail

build_wasm() {
  wasm-pack build
}

# wasm-pack fetches the wasm-bindgen CLI with no timeout and stalls (galaxy-gen#89), so
# get the pinned one here, bounded. wasm-pack uses a matching one on PATH.
prefetch_wasm_bindgen() {
  local version target dir
  version=$(awk '/^name = "wasm-bindgen"$/ {getline; gsub(/[^0-9.]/, ""); print; exit}' Cargo.lock)
  if [ -z "$version" ] || [ "$(uname -s)" != "Linux" ]; then
    return 0
  fi
  if wasm-bindgen --version 2>/dev/null | grep -q " ${version}$"; then
    return 0
  fi
  case "$(uname -m)" in
    x86_64) target=x86_64-unknown-linux-musl ;;
    aarch64 | arm64) target=aarch64-unknown-linux-gnu ;;
    *) return 0 ;;
  esac
  dir=$(mktemp -d)
  if ! curl --retry 3 --retry-all-errors --retry-delay 3 --connect-timeout 10 --max-time 60 -fsSL \
    -o "$dir/wasm-bindgen.tar.gz" \
    "https://github.com/rustwasm/wasm-bindgen/releases/download/${version}/wasm-bindgen-${version}-${target}.tar.gz" ||
    ! tar -xzf "$dir/wasm-bindgen.tar.gz" -C "$dir" --strip-components=1; then
    echo "::error::could not fetch wasm-bindgen ${version}, which wasm-pack would stall on" >&2
    exit 1
  fi
  export PATH="$dir:$PATH"
}

test_rust() {
  cargo check
  cargo test -- --color always
}

# The single definition of the Rust lint gate. CI calls this script rather than
# repeating the flags, so local and CI cannot drift apart.
lint_rust() {
  cargo clippy --all-targets -- -D warnings
  cargo fmt --check
}

test_e2e() {
  build_wasm
  npm install ./pkg --no-save
  npx playwright test
}

case "${1:-}" in
  install)
    cargo build
    # Unconditional install would overwrite dev-base's pinned wasm-pack in the
    # shared CARGO_HOME/bin with a floating one (galaxy-gen#74).
    if ! command -v wasm-pack >/dev/null 2>&1; then
      cargo install wasm-pack
    fi
    build_wasm
    npm install
    npx playwright install chromium
    ;;
  deps-sync)
    npm install --package-lock-only
    ;;
  ci-setup)
    # Lockfile-exact deps plus the wasm package, which check-js needs for the
    # galaxy_gen_backend types. CI installs no toolchain: dev-base supplies it.
    npm ci
    prefetch_wasm_bindgen
    build_wasm
    npm install ./pkg --no-save
    ;;
  test-rust)
    test_rust
    ;;
  format-rust)
    cargo fmt
    ;;
  lint-rust)
    lint_rust
    ;;
  build-rust)
    build_wasm
    cargo build
    ;;
  build-wasm)
    build_wasm
    ;;
  debug-sim)
    shift
    cargo run --release --bin debug_sim -- "$@"
    ;;
  build-js-prod)
    build_wasm
    npx webpack --config webpack.config.js --mode production
    ;;
  check-js)
    npm run lint
    npm run typecheck
    ;;
  capture-readme)
    node scripts/capture-readme.mjs
    ;;
  promote-readme)
    candidate="${GALAXY_CAPTURE_OUTPUT:-docs/project-galaxy-gen.next.gif}"
    tracked="docs/project-galaxy-gen.gif"
    if [[ "${candidate}" == "${tracked}" || ! -f "${candidate}" ]]; then
      echo "capture candidate not found or not safely separated: ${candidate}" >&2
      exit 2
    fi
    mv -f -- "${candidate}" "${tracked}"
    rm -f -- docs/project-galaxy-gen.next.gif docs/project-galaxy-gen.next2.gif
    ;;
  dev)
    echo "Starting rust watcher + JS dev server (Ctrl-C stops both)"
    trap 'kill 0' INT TERM EXIT
    cargo watch -w src/rust -w Cargo.toml -s "wasm-pack build && touch src/js/index.js" &
    webpack_args=(serve --open)
    if [[ -n "${GALAXY_DEV_PORT:-}" ]]; then
      webpack_args+=(--port "${GALAXY_DEV_PORT}")
    fi
    npx webpack "${webpack_args[@]}" &
    wait
    ;;
  dev-js)
    npx webpack serve --open
    ;;
  dev-rust)
    cargo watch -w src/rust -w Cargo.toml -s "wasm-pack build && touch src/js/index.js"
    ;;
  test-e2e)
    test_e2e
    ;;
  perf-profile)
    shift
    cargo run --release --bin perf_profile -- "$@"
    ;;
  test-perf)
    # Real GPU, not the default config's SwiftShader: Canvas2D cost
    # attribution is meaningless under software rasterization.
    build_wasm
    npm install ./pkg --no-save
    npx playwright test --config playwright.gpu.config.ts --headed --workers=1 \
      render-perf runtime-perf
    ;;
  test-e2e-ui)
    build_wasm
    npm install ./pkg --no-save
    npx playwright test --ui
    ;;
  test)
    lint_rust
    test_rust
    test_e2e
    ;;
  build-docker)
    image="${IMAGE_NAME:-galaxy-gen}"
    git_hash="${GIT_HASH:-$(git rev-parse HEAD 2>/dev/null || echo dev)}"
    docker build \
      --platform linux/amd64 \
      --progress plain \
      --build-arg BUILDKIT_INLINE_CACHE=1 \
      --cache-from "${image}:latest" \
      -t "${image}:${git_hash}" \
      -t "${image}:latest" \
      .
    ;;
  run-docker)
    image="${IMAGE_NAME:-galaxy-gen}"
    docker run --rm --platform linux/amd64 -p 8080:8080 "${image}:latest"
    ;;
  *)
    echo "unknown Ward action: ${1:-}" >&2
    exit 2
    ;;
esac
