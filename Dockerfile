# syntax=docker/dockerfile:1.7

# Stage 1: build Rust -> WASM -> JS static bundle
# The retired dev-base image is replaced by the official Rust image at the rust-toolchain.toml
# pin, with Node copied from the official Node image and the pinned wasm-pack release.
FROM rust:1.90-bookworm AS builder

COPY --from=node:22-bookworm-slim /usr/local/bin/node /usr/local/bin/node
COPY --from=node:22-bookworm-slim /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -s ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx && \
    rustup target add wasm32-unknown-unknown
COPY scripts/ci/install-wasm-pack.sh /tmp/install-wasm-pack.sh
RUN bash /tmp/install-wasm-pack.sh

WORKDIR /app

# Cache rust deps: copy manifests and build a shim first.
COPY Cargo.toml Cargo.lock ./
RUN mkdir -p src/rust && \
    echo "fn main() {}" > src/rust/lib.rs && \
    cargo fetch

# Now the real sources.
COPY src ./src
RUN wasm-pack build --release --out-dir pkg

# Node dependencies + build
COPY package.json package-lock.json ./
COPY webpack.config.js postcss.config.js tsconfig.json ./
RUN npm ci
RUN npm install ./pkg --no-save

# The browser DSN is public by design, but it stays out of tracked files.
ARG SENTRY_DSN=""
RUN SENTRY_DSN="$SENTRY_DSN" npm run build

# Stage 2: unprivileged nginx serving the built bundle.
FROM nginxinc/nginx-unprivileged:1.27-alpine AS runtime

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html
