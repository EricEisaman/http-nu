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

### 1. Nushell Streaming Semantics
**Problem:** `$in` is a stream and can only be consumed once. Using it multiple times (e.g., parsing JSON AND using it as metadata) will result in data loss or empty values.
**Solution:** Always capture `$in` to a variable if we need it more than once.
```nu
let body = ($in | decode utf-8) # Capture first!
$body | from json | ...
... metadata $body
```

### 2. Loose Type Signatures
**Problem:** Strict Nushell return types (e.g., `-> record`) in helper functions can cause parse errors or runtime failures if the pipeline input is slightly different (e.g. `any` or `nothing`).
**Solution:** Prefer omitting type signatures or using `any` for internal helper functions unless strict contract validation is explicitly needed.

### 3. Static Assets & Docker
**Problem:** Static files (like `www/`) failing to appear in production.
**Solution:**
- Always check `.dockerignore` when adding new asset directories.
- `Dockerfile` `COPY` commands respect `.dockerignore`, so what's ignored won't be copied even if explicitly requested.

### 4. Aesthetics are Critical
**Problem:** "Basic" styling is insufficient.
**Solution:** ALWAYS use the `core.css` design system.
- Use `shadow-offset`, `shadow-float`, `rotate-ccw-1` for the "Retro/Sticker" look.
- Use `text-header`, `bg-dark`, `text-accent` color tokens.
- Never rely on browser defaults.

### 5. Datastar Robustness
**Problem:** Datastar helpers failing on different input types.
**Solution:** Helper functions like `from datastar-signals` must accept `any` input to handle potential raw binary streams, strings, or pre-parsed records.
