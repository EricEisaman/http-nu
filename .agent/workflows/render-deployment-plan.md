---
description: Plan for configuring http-nu for Docker deployment on Render.com
---

# Render.com Docker Deployment Plan for http-nu

## Project Analysis

**http-nu** is a Rust-based HTTP server that uses Nushell for scripting. Key characteristics:
- **Language**: Rust (Cargo-based build system)
- **Current Version**: 0.10.2
- **Rust Version**: 1.88.0
- **Build System**: Uses Dagger for cross-platform builds in CI/CD
- **Dependencies**: Nushell runtime, TLS support (rustls), optional cross-stream feature
- **Typical Usage**: CLI tool that serves HTTP requests with Nushell script handlers

## Deployment Strategy

### 1. Multi-Stage Dockerfile

Create an optimized multi-stage Dockerfile that:
- **Stage 1 (Builder)**: Compile the Rust binary
  - Use official Rust image as base
  - Cache dependencies for faster rebuilds
  - Build in release mode with optimizations
  - Target: Linux x86_64 (amd64) for Render.com compatibility
  
- **Stage 2 (Runtime)**: Minimal runtime image
  - Use slim/distroless base image
  - Copy only the compiled binary
  - No build tools or source code
  - Minimal attack surface and smaller image size

### 2. Docker Configuration Files

**Dockerfile**: Multi-stage build optimized for production
- Leverage Docker layer caching
- Use cargo-chef for dependency caching
- Strip debug symbols for smaller binary
- Set proper permissions and non-root user

**.dockerignore**: Exclude unnecessary files
- Target directory (build artifacts)
- Git history
- Documentation
- Test files
- CI/CD configurations

### 3. Render.com Configuration

**render.yaml**: Infrastructure as Code for Render
- Define web service configuration
- Specify Docker build context
- Configure environment variables
- Set health check endpoints
- Define resource allocation (CPU/RAM)
- Configure auto-deploy settings

### 4. Application Configuration

**Default Handler**: Create a production-ready default handler
- Health check endpoint (`/health`)
- Metrics endpoint (optional)
- Example routes demonstrating capabilities
- Proper error handling
- Logging configuration

### 5. Environment Variables

Required/Optional environment variables:
- `PORT`: Render provides this automatically (default: 10000)
- `LOG_FORMAT`: Set to `jsonl` for production logging
- `RUST_LOG`: Control log verbosity
- Custom app-specific variables

## Implementation Steps

### Step 1: Create Dockerfile
- Multi-stage build with cargo-chef for caching
- Use rust:1.88-slim-bookworm for builder
- Use debian:bookworm-slim for runtime
- Install minimal runtime dependencies
- Configure non-root user

### Step 2: Create .dockerignore
- Exclude build artifacts
- Exclude development files
- Keep only necessary source files

### Step 3: Create render.yaml
- Define web service type
- Set Docker build configuration
- Configure environment variables
- Set health check path
- Define scaling/resource settings

### Step 4: Create Production Handler
- Create `serve.nu` or similar default handler
- Include health check endpoint
- Add example routes
- Configure proper logging

### Step 5: Documentation
- Update README with Docker instructions
- Add deployment guide for Render.com
- Document environment variables
- Include troubleshooting section

## Key Considerations

### Performance
- Use release build with LTO (already configured in Cargo.toml)
- Minimize Docker image size
- Use layer caching effectively
- Consider using cargo-chef for faster rebuilds

### Security
- Run as non-root user
- Use minimal base images
- Don't include secrets in image
- Use environment variables for configuration

### Reliability
- Implement health checks
- Configure proper logging
- Handle graceful shutdown
- Set resource limits

### Render.com Specifics
- Render uses `PORT` environment variable (must bind to 0.0.0.0:$PORT)
- Free tier has limitations (512MB RAM, sleeps after inactivity)
- Docker builds happen on Render's infrastructure
- Auto-deploy on git push (if configured)

## Expected File Structure

```
http-nu/
├── Dockerfile              # Multi-stage Docker build
├── .dockerignore          # Docker build exclusions
├── render.yaml            # Render.com service configuration
├── serve.nu               # Default production handler (optional)
├── docker-compose.yml     # Local development (optional)
└── docs/
    └── DEPLOYMENT.md      # Deployment documentation
```

## Testing Strategy

1. **Local Docker Build**: Test Dockerfile locally
   ```bash
   docker build -t http-nu .
   docker run -p 3001:3001 http-nu
   ```

2. **Local Docker Compose**: Test with docker-compose
   ```bash
   docker-compose up
   ```

3. **Render Preview**: Deploy to Render preview environment

4. **Production Deploy**: Deploy to production service

## Success Criteria

- ✅ Dockerfile builds successfully
- ✅ Docker image size < 100MB (optimized)
- ✅ Application starts and responds to requests
- ✅ Health check endpoint works
- ✅ Logs are properly formatted (jsonl)
- ✅ Render.com deployment succeeds
- ✅ Application accessible via Render URL
- ✅ Auto-deploy works on git push
