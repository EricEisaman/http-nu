# Sample Dockerfile for http-nu
# This is a reference implementation showing the recommended multi-stage build approach

# ============================================================================
# Stage 1: Dependency Planner (cargo-chef)
# ============================================================================
FROM rust:slim-bookworm AS chef

# Install cargo-chef for dependency caching
RUN cargo install cargo-chef

WORKDIR /app

# ============================================================================
# Stage 2: Dependency Planner execution
# ============================================================================
FROM chef AS planner

# Copy all files to ensure all workspace members' Cargo.toml files are present
COPY . .

# Generate dependency recipe
RUN cargo chef prepare --recipe-path recipe.json

# ============================================================================
# Stage 3: Build Dependencies
# ============================================================================
FROM chef AS dependencies

# Install build dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

COPY --from=planner /app/recipe.json recipe.json

# Build dependencies only (cached layer)
RUN cargo chef cook --release --recipe-path recipe.json

# ============================================================================
# Stage 4: Build Application
# ============================================================================
FROM dependencies AS builder

WORKDIR /app

# Copy source code
COPY . .

# Build the application
# Note: LTO and codegen-units are already configured in Cargo.toml
RUN cargo build --release --locked

# Strip debug symbols to reduce binary size
RUN strip target/release/http-nu

# ============================================================================
# Stage 5: Runtime Image
# ============================================================================
FROM debian:bookworm-slim AS runtime

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libssl3 \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -u 1000 -s /bin/bash http-nu

# Set working directory
WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/target/release/http-nu /usr/local/bin/http-nu

# Copy examples directory (all examples with their handlers)
COPY examples /app/examples

# Copy production handler
COPY serve.nu /app/serve.nu

# Set ownership
RUN chown -R http-nu:http-nu /app

# Switch to non-root user
USER http-nu

# Expose port (Render will override with PORT env var)
EXPOSE 3001

# Environment variables with defaults
ENV PORT=3001 \
    LOG_FORMAT=jsonl \
    RUST_LOG=info

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${PORT}/health || exit 1

# Default command - runs production handler with all examples
# Store is created at /app/store (writable by http-nu user)
CMD ["sh", "-c", "http-nu --store /app/store :${PORT} /app/serve.nu"]

# ============================================================================
# Build Instructions:
# ============================================================================
# docker build -t http-nu:latest .
# docker run -p 3001:3001 http-nu:latest
# docker run -p 3001:3001 -v $(pwd)/serve.nu:/app/serve.nu http-nu:latest http-nu :3001 /app/serve.nu
