#!/usr/bin/env bash
# Installs the pinned wasm-pack release binary into cargo's bin dir. Not `cargo install`:
# its newest dependencies need a newer rustc than rust-toolchain.toml pins, and a source
# build costs minutes on every run. The checksums came from the v0.15.1 release assets.
set -euo pipefail

VER="${WASM_PACK_VERSION:-v0.15.1}"
case "$(uname -m)" in
  x86_64)
    arch=x86_64
    sha=410101009739b9d01c7d5affaaad6e9c9a24b4cba6791a4805db8e89b9bf7af2 ;;
  aarch64 | arm64)
    arch=aarch64
    sha=7004853c7925ae1984033b5f25866ec604bbc921ef956d5e6c5595bc5af6d30c ;;
  *) echo "install-wasm-pack: unsupported arch $(uname -m)" >&2; exit 1 ;;
esac

name="wasm-pack-${VER}-${arch}-unknown-linux-musl"
dest="${CARGO_HOME:-$HOME/.cargo}/bin"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

curl --retry 3 --retry-all-errors -fsSL -o "$work/wp.tgz" \
  "https://github.com/wasm-bindgen/wasm-pack/releases/download/${VER}/${name}.tar.gz"
echo "${sha}  $work/wp.tgz" | sha256sum -c - >/dev/null
tar -xzf "$work/wp.tgz" -C "$work"
mkdir -p "$dest"
install -m 0755 "$work/${name}/wasm-pack" "$dest/wasm-pack"
"$dest/wasm-pack" --version
