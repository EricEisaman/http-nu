---
artifact_type: implementation_plan
summary: |
  Detailed implementation plan for adding Docker support and Render.com deployment 
  configuration to the http-nu project. Includes Dockerfile creation, render.yaml 
  configuration, production handler setup, and documentation updates.
---

# Docker & Render.com Deployment Implementation Plan

## Overview
This plan outlines the steps to configure the http-nu project for Docker-based deployment on Render.com, including all necessary configuration files, handlers, and documentation.

---

## Phase 1: Docker Configuration

### Task 1.1: Create Dockerfile
**File**: `/Dockerfile`
**Priority**: High
**Estimated Effort**: 2-3 hours

**Requirements**:
- Multi-stage build for optimal image size
- Stage 1: Build stage using `rust:1.88-slim-bookworm`
  - Install build dependencies
  - Use cargo-chef for dependency caching
  - Build with `--release --locked`
  - Enable all default features including cross-stream
- Stage 2: Runtime stage using `debian:bookworm-slim`
  - Install minimal runtime dependencies (ca-certificates, libssl3)
  - Copy binary from build stage
  - Create non-root user (http-nu)
  - Set proper permissions
  - Configure ENTRYPOINT and CMD

**Key Considerations**:
- Leverage existing Cargo.toml optimizations (LTO, codegen-units=1)
- Support both default features and minimal builds
- Bind to `0.0.0.0:${PORT}` for Render compatibility
- Target size: < 100MB compressed

### Task 1.2: Create .dockerignore
**File**: `/.dockerignore`
**Priority**: Medium
**Estimated Effort**: 30 minutes

**Requirements**:
- Exclude build artifacts (`target/`, `*.log`)
- Exclude development files (`.git/`, `.github/`, `.dagger/`)
- Exclude documentation (`docs/`, `*.md` except essential)
- Exclude test files (`tests/`, `benchmarks/`)
- Keep necessary files (source, Cargo.*, build.rs, syntaxes/)

### Task 1.3: Create docker-compose.yml (Optional)
**File**: `/docker-compose.yml`
**Priority**: Low
**Estimated Effort**: 1 hour

**Requirements**:
- Local development setup
- Volume mounts for hot-reload
- Port mapping (3001:3001)
- Environment variable configuration
- Optional: Include cross-stream store volume

---

## Phase 2: Render.com Configuration

### Task 2.1: Create render.yaml
**File**: `/render.yaml`
**Priority**: High
**Estimated Effort**: 1-2 hours

**Requirements**:
- Define web service with Docker runtime
- Configure build settings:
  - Docker context: `.`
  - Dockerfile path: `./Dockerfile`
- Environment variables:
  - `LOG_FORMAT=jsonl`
  - `RUST_LOG=info`
- Health check configuration:
  - Path: `/health`
  - Interval: 30s
  - Timeout: 10s
- Resource allocation:
  - Plan: starter (or free for testing)
  - Auto-deploy: true
- Region: oregon (or user preference)

**Service Types to Consider**:
1. **Web Service**: Primary HTTP service
2. **Background Worker**: Optional for --services mode with store

---

## Phase 3: Production Handler & Configuration

### Task 3.1: Create Production Handler
**File**: `/serve.nu` or `/examples/production.nu`
**Priority**: High
**Estimated Effort**: 2 hours

**Requirements**:
- Health check endpoint (`/health` returns 200 OK)
- Root endpoint with service information
- Example routes demonstrating capabilities:
  - JSON responses
  - Static file serving (if applicable)
  - SSE endpoint (optional)
- Proper error handling (404, 500)
- Logging best practices
- Use router module for clean route definitions

**Example Structure**:
```nushell
use http-nu/router *

{|req|
  dispatch $req [
    (route {path: "/health"} {|req ctx| 
      {status: "ok", version: "0.10.2"}
    })
    
    (route {path: "/"} {|req ctx|
      {
        service: "http-nu",
        version: "0.10.2",
        endpoints: ["/health", "/api/echo", "/api/time"]
      }
    })
    
    (route {method: "POST", path: "/api/echo"} {|req ctx|
      $in
    })
    
    (route {path: "/api/time"} {|req ctx|
      {timestamp: (date now | into int)}
    })
    
    (route true {|req ctx|
      "Not Found" | metadata set --merge {'http.response': {status: 404}}
    })
  ]
}
```

### Task 3.2: Create Entrypoint Script (Optional)
**File**: `/docker-entrypoint.sh`
**Priority**: Low
**Estimated Effort**: 1 hour

**Requirements**:
- Handle environment variable defaults
- Support different run modes (serve file vs inline)
- Graceful shutdown handling
- Health check support

---

## Phase 4: Documentation

### Task 4.1: Create Deployment Guide
**File**: `/docs/DEPLOYMENT.md`
**Priority**: Medium
**Estimated Effort**: 2 hours

**Requirements**:
- Docker build instructions
- Local testing with Docker
- Render.com deployment steps
- Environment variable reference
- Troubleshooting guide
- Performance tuning tips

### Task 4.2: Update README.md
**File**: `/README.md`
**Priority**: Medium
**Estimated Effort**: 1 hour

**Requirements**:
- Add "Deployment" section
- Link to DEPLOYMENT.md
- Add Docker quick start
- Add Render.com badge (after deployment)
- Update installation section with Docker option

### Task 4.3: Create Example .env File
**File**: `/.env.example`
**Priority**: Low
**Estimated Effort**: 30 minutes

**Requirements**:
- Document all environment variables
- Provide sensible defaults
- Include comments explaining each variable

---

## Phase 5: Testing & Validation

### Task 5.1: Local Docker Testing
**Priority**: High
**Estimated Effort**: 2 hours

**Test Cases**:
1. Build Docker image successfully
   ```bash
   docker build -t http-nu:test .
   ```
2. Run container and verify startup
   ```bash
   docker run -p 3001:3001 http-nu:test
   ```
3. Test health check endpoint
   ```bash
   curl http://localhost:3001/health
   ```
4. Test example endpoints
5. Verify logging format (jsonl)
6. Check image size (should be < 100MB)
7. Test with custom handler file
8. Test environment variable configuration

### Task 5.2: Render.com Preview Deployment
**Priority**: High
**Estimated Effort**: 1 hour

**Steps**:
1. Create Render account (if needed)
2. Connect GitHub repository
3. Create new Web Service
4. Configure from render.yaml
5. Deploy and monitor build logs
6. Verify deployment success
7. Test deployed endpoints
8. Check logs and metrics

### Task 5.3: Performance Testing
**Priority**: Medium
**Estimated Effort**: 2 hours

**Metrics to Measure**:
- Cold start time
- Response latency
- Memory usage
- CPU usage
- Concurrent request handling
- Image build time

---

## Phase 6: CI/CD Integration (Optional)

### Task 6.1: Add Docker Build to GitHub Actions
**File**: `/.github/workflows/docker.yml`
**Priority**: Low
**Estimated Effort**: 2 hours

**Requirements**:
- Build Docker image on PR
- Push to Docker Hub or GitHub Container Registry
- Tag with version and latest
- Multi-platform builds (amd64, arm64)
- Cache layers for faster builds

---

## Implementation Checklist

### Pre-Implementation
- [ ] Review existing build system (Dagger)
- [ ] Understand Render.com requirements
- [ ] Review Rust/Cargo best practices for Docker
- [ ] Check for any platform-specific dependencies

### Core Implementation
- [ ] Create Dockerfile with multi-stage build
- [ ] Create .dockerignore
- [ ] Create render.yaml
- [ ] Create production handler (serve.nu)
- [ ] Test Docker build locally
- [ ] Test Docker run locally

### Documentation
- [ ] Create DEPLOYMENT.md
- [ ] Update README.md
- [ ] Create .env.example
- [ ] Add inline comments to configuration files

### Testing
- [ ] Local Docker build test
- [ ] Local Docker run test
- [ ] Health check verification
- [ ] Endpoint functionality tests
- [ ] Render.com preview deployment
- [ ] Production deployment test

### Optional Enhancements
- [ ] Create docker-compose.yml
- [ ] Create docker-entrypoint.sh
- [ ] Add GitHub Actions Docker workflow
- [ ] Add Render.com badge to README
- [ ] Create deployment automation scripts

---

## Risk Assessment

### High Risk
- **Dependency compilation issues**: Some Rust crates may have platform-specific build requirements
  - *Mitigation*: Test build early, use well-supported base images
  
- **Binary size**: Rust binaries can be large
  - *Mitigation*: Use strip, UPX compression, minimal base image

### Medium Risk
- **Render.com resource limits**: Free tier has strict limits
  - *Mitigation*: Document resource requirements, test on free tier first

- **Port binding**: Application must bind to Render's PORT variable
  - *Mitigation*: Make port configurable, default to 0.0.0.0:${PORT:-3001}

### Low Risk
- **Build time**: Rust compilation can be slow
  - *Mitigation*: Use cargo-chef for caching, leverage Render's build cache

---

## Success Metrics

1. **Docker Image**:
   - ✅ Builds successfully in < 10 minutes
   - ✅ Final image size < 100MB
   - ✅ Runs without errors
   - ✅ All endpoints respond correctly

2. **Render Deployment**:
   - ✅ Deploys successfully from render.yaml
   - ✅ Health checks pass
   - ✅ Application accessible via public URL
   - ✅ Auto-deploy works on git push
   - ✅ Logs are properly formatted and accessible

3. **Performance**:
   - ✅ Cold start < 30 seconds
   - ✅ Response time < 100ms for simple endpoints
   - ✅ Memory usage < 256MB under normal load
   - ✅ Handles 100+ concurrent requests

4. **Documentation**:
   - ✅ Clear deployment instructions
   - ✅ All environment variables documented
   - ✅ Troubleshooting guide included
   - ✅ Examples provided

---

## Timeline Estimate

- **Phase 1 (Docker)**: 4-5 hours
- **Phase 2 (Render)**: 1-2 hours
- **Phase 3 (Handler)**: 2-3 hours
- **Phase 4 (Docs)**: 3-4 hours
- **Phase 5 (Testing)**: 5-6 hours
- **Phase 6 (CI/CD)**: 2-3 hours (optional)

**Total**: 17-23 hours (core implementation: 15-20 hours)

---

## Next Steps

1. Review and approve this implementation plan
2. Begin with Phase 1: Create Dockerfile
3. Test Docker build locally before proceeding
4. Iterate through phases sequentially
5. Test thoroughly at each phase
6. Deploy to Render.com preview environment
7. Validate and document any issues
8. Deploy to production
