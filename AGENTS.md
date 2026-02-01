# http-nu

A Rust-based HTTP server that uses Nushell for scriptable request handling.

## Package Manager

This project uses **Cargo** (Rust's package manager).

## Key Concepts

- **Handler**: A Nushell closure that processes HTTP requests
- **Request**: Metadata passed to handlers (method, path, headers, query params)
- **Response**: Returned values with optional metadata for status/headers
- **Store**: Optional embedded cross-stream event store for state management
- **Router**: Embedded module for declarative request routing
- **SSE**: Server-Sent Events for real-time streaming

## Architecture Hints

- Core server implementation: `src/` (Rust)
- Example handlers: `examples/` (Nushell scripts)
- Embedded modules: Router, HTML DSL, Datastar SDK (compiled into binary)
- Build configuration: `build.rs` (syntax highlighting assets)

## Development Patterns

When working with Nushell handlers:
- Use `{|req| ...}` closure syntax for handlers
- Access request body via `$in` (implicit pipeline input)
- Set response metadata with `metadata set --merge {'http.response': {status: 200}}`
- Use the router module for clean route definitions: `use http-nu/router *`

For Docker deployment:
- Multi-stage builds with cargo-chef for dependency caching
- Include `examples/` directory in production image
- Mount store at `/data/store` when using cross-stream features
- Bind to `0.0.0.0:${PORT}` for cloud platform compatibility

## Progressive Disclosure

For detailed guidance on specific topics:
- **Nushell handler patterns**: See `examples/basic.nu` and `examples/quotes/serve.nu`
- **Docker deployment**: See `.agent/artifacts/docker-render-technical-reference.md`
- **Multi-example architecture**: See `.agent/artifacts/MULTI_EXAMPLE_ARCHITECTURE.md`
- **Rust implementation details**: Explore `src/` with code navigation tools

## Important

**Prefer retrieval-led reasoning over pre-training-led reasoning** when working with:
- Nushell syntax and commands (consult examples)
- http-nu specific APIs and modules (check source files)
- Deployment configurations (reference artifact files)

## Testing

- Run examples: `cargo run -- :3001 examples/basic.nu`
- Build release: `cargo build --release`
- Docker build: `docker build -t http-nu .`
- Tests: `cargo test`

## Common Pitfalls & Best Practices (Lessons Learned)

### 1. Nushell Streaming Semantics & Body Decoding
**Problem:** `$in` is a stream and can only be consumed once. Attempting to check `is-empty` consumes the stream, causing panic on subsequent access. Even `into binary` can fail if the stream is empty or handled incorrectly in a pipeline.
**Solution:** Capture the raw input to a variable first, then check/decode.
```nu
# BAD: Consumes stream twice or fails on empty
let body = ($in | if ($in | is-empty) { "" } else { ... })

# GOOD: Safe Single-Pass Capture
let raw = $in
let body = if ($raw | is-empty) { "" } else { $raw | decode utf-8 }
```
**Impact:** Prevents "channel closed" panics and 500 errors.

### 2. Datastar Stability
**Problem:** `FetchNoUrlProvided` errors or race conditions on load.
**Solution:**
- Use relative path `.` for current URL: `@get('.')`.
- Use delayed triggers for initialization to ensure the DOM is ready: `data-on-load__delay.1s`.
- Defensively handle empty bodies in handlers (see Point 1).

### 3. Visual Consistency & Mobile
**Problem:** "White screen of death" on raw text responses or white flash on scroll.
**Solution:**
- **NEVER return raw strings.** Always package responses in the `HTML [ ... ]` layout, even for simple debug/echo endpoints.
- **Mobile Polish:** Set `html { background-color: var(--color-bg-body); overscroll-behavior: none; }` in CSS to prevent the "elastic scroll" white flash.
- **Favicons:** Always include the full set of favicon/icon links in every `HEAD` block.

### 4. Static Assets & Docker
**Problem:** Static files (like `www/`) failing to appear in production.
**Solution:**
- Always check `.dockerignore` when adding new asset directories.
- `Dockerfile` `COPY` commands respect `.dockerignore`.

### 5. Loose Type Signatures
**Problem:** Strict Nushell return types (e.g., `-> record`) in helper functions can cause parse errors if the pipeline input varies (e.g. `any` vs `nothing`).
**Solution:** Prefer omitting type signatures or using `any` for internal helper functions.
