# Docker & Render.com Deployment - Technical Reference

## Quick Start Commands

```bash
# Build Docker image locally
docker build -t http-nu:latest .

# Run locally
docker run -p 3001:3001 -e PORT=3001 http-nu:latest

# Test health check
curl http://localhost:3001/health

# Build and run with docker-compose
docker-compose up --build
```

## File Overview

### Dockerfile
**Purpose**: Multi-stage Docker build for optimized production image  
**Location**: `/Dockerfile`  
**Base Images**:
- Builder: `rust:1.88-slim-bookworm`
- Runtime: `debian:bookworm-slim`

**Key Features**:
- Cargo-chef for dependency caching
- Release build with LTO optimizations
- Non-root user execution
- Minimal runtime dependencies
- Target size: ~50-80MB

### render.yaml
**Purpose**: Render.com service configuration (Infrastructure as Code)  
**Location**: `/render.yaml`  
**Service Type**: Web Service (Docker)

**Key Settings**:
- Auto-deploy on git push
- Health check: `/health`
- Environment: `LOG_FORMAT=jsonl`
- Port: Automatically set by Render

### serve.nu
**Purpose**: Production-ready default HTTP handler  
**Location**: `/serve.nu` or `/examples/production.nu`

**Endpoints**:
- `GET /health` - Health check (returns 200 OK)
- `GET /` - Service info and available endpoints
- `POST /api/echo` - Echo request body
- `GET /api/time` - Current timestamp
- `*` - 404 handler

### .dockerignore
**Purpose**: Exclude unnecessary files from Docker build context  
**Location**: `/.dockerignore`

**Excludes**:
- Build artifacts (`target/`)
- Git history (`.git/`)
- CI/CD configs (`.github/`, `.dagger/`)
- Documentation (`docs/`, most `*.md`)
- Tests and benchmarks

## Environment Variables

| Variable | Default | Description | Required |
|----------|---------|-------------|----------|
| `PORT` | `3001` | HTTP server port (Render sets this) | Yes |
| `LOG_FORMAT` | `human` | Log format (`human` or `jsonl`) | No |
| `RUST_LOG` | `info` | Log level | No |
| `HANDLER_FILE` | `/serve.nu` | Path to Nushell handler script | No |

## Docker Build Arguments

| Argument | Default | Description |
|----------|---------|-------------|
| `RUST_VERSION` | `1.88` | Rust version to use |
| `FEATURES` | `default` | Cargo features to enable |

## Render.com Configuration

### Service Settings
- **Type**: Web Service
- **Runtime**: Docker
- **Region**: Oregon (or closest to users)
- **Plan**: Starter ($7/month) or Free (with limitations)
- **Auto-Deploy**: Enabled (deploys on git push to main)

### Health Check
- **Path**: `/health`
- **Interval**: 30 seconds
- **Timeout**: 10 seconds
- **Unhealthy Threshold**: 3 failures

### Resource Limits (Free Tier)
- **RAM**: 512 MB
- **CPU**: Shared
- **Build Time**: 15 minutes max
- **Disk**: 1 GB
- **Sleep**: After 15 min inactivity

### Resource Limits (Starter Tier)
- **RAM**: 512 MB
- **CPU**: 0.5 vCPU
- **Build Time**: No limit
- **Disk**: 1 GB
- **Sleep**: Never

## Build Process

### Local Build Steps
1. Docker reads Dockerfile
2. Stage 1: Install Rust and dependencies
3. Use cargo-chef to cache dependencies
4. Compile http-nu in release mode
5. Stage 2: Copy binary to slim runtime image
6. Configure non-root user and permissions
7. Set entrypoint and default command

**Estimated Build Time**: 5-10 minutes (first build), 2-3 minutes (cached)

### Render Build Steps
1. Render clones repository
2. Reads render.yaml configuration
3. Builds Docker image using Dockerfile
4. Pushes image to internal registry
5. Deploys container to service
6. Runs health checks
7. Routes traffic to new deployment

**Estimated Deploy Time**: 8-15 minutes total

## Port Binding

**Critical**: Application MUST bind to `0.0.0.0:${PORT}` for Render compatibility.

```nushell
# In serve.nu or command line
# Render sets PORT environment variable
http-nu :${PORT} ./handler.nu
```

**Dockerfile CMD**:
```dockerfile
CMD ["http-nu", ":${PORT:-3001}", "/app/serve.nu"]
```

## Logging

### Development (Local)
```bash
# Human-readable format
docker run -e LOG_FORMAT=human http-nu:latest
```

### Production (Render)
```bash
# Structured JSON logs
docker run -e LOG_FORMAT=jsonl http-nu:latest
```

**Log Output** (jsonl):
```json
{"stamp":"...","message":"started","address":"http://0.0.0.0:10000","startup_ms":42}
{"stamp":"...","message":"request","request_id":"...","method":"GET","path":"/health"}
{"stamp":"...","message":"response","request_id":"...","status":200}
{"stamp":"...","message":"complete","request_id":"...","bytes":15,"duration_ms":2}
```

## Troubleshooting

### Build Fails
- **Issue**: Dependency compilation errors
- **Solution**: Check Rust version, update dependencies, review build logs

### Container Won't Start
- **Issue**: Binary not found or permission denied
- **Solution**: Verify COPY paths in Dockerfile, check file permissions

### Health Check Fails
- **Issue**: `/health` endpoint not responding
- **Solution**: Verify handler includes health endpoint, check port binding

### High Memory Usage
- **Issue**: Container using > 512MB RAM
- **Solution**: Optimize handler, reduce concurrent connections, upgrade plan

### Slow Cold Starts
- **Issue**: Container takes > 30s to start
- **Solution**: Optimize Dockerfile, reduce binary size, use Starter plan

## Security Best Practices

1. **Non-root User**: Container runs as `http-nu` user (UID 1000)
2. **Minimal Base Image**: Debian slim with only essential packages
3. **No Secrets in Image**: Use environment variables for sensitive data
4. **Updated Dependencies**: Regular `cargo update` and base image updates
5. **Read-only Filesystem**: Consider mounting volumes as read-only

## Performance Optimization

### Docker Image Size
- Use multi-stage builds ✅
- Strip debug symbols ✅
- Use slim base images ✅
- Consider UPX compression (optional)
- Remove unnecessary dependencies

### Runtime Performance
- Enable LTO in Cargo.toml ✅
- Use release build ✅
- Set `codegen-units = 1` ✅
- Consider using jemalloc allocator
- Profile and optimize hot paths

### Caching Strategy
- Cargo-chef for dependency caching ✅
- Docker layer caching ✅
- Render build cache ✅
- CDN for static assets (if applicable)

## Monitoring & Observability

### Render Dashboard
- View logs in real-time
- Monitor CPU/memory usage
- Track request metrics
- View deployment history
- Configure alerts

### Custom Metrics (Optional)
- Add `/metrics` endpoint
- Export Prometheus metrics
- Integrate with monitoring service
- Track custom business metrics

## Cost Estimation

### Free Tier
- **Cost**: $0/month
- **Limitations**: Sleeps after 15 min, 750 hours/month
- **Best For**: Testing, demos, low-traffic apps

### Starter Tier
- **Cost**: $7/month
- **Benefits**: No sleep, always on, faster builds
- **Best For**: Production apps, small-medium traffic

### Standard Tier
- **Cost**: $25/month
- **Benefits**: More resources, better performance
- **Best For**: High-traffic production apps

## Deployment Workflow

### Manual Deployment
1. Push code to GitHub
2. Render auto-detects changes
3. Triggers build from render.yaml
4. Builds Docker image
5. Runs health checks
6. Switches traffic to new version

### Preview Deployments
1. Create pull request
2. Render creates preview environment
3. Test changes in isolation
4. Merge to deploy to production

### Rollback
1. Go to Render dashboard
2. Select previous deployment
3. Click "Rollback"
4. Traffic switches to previous version

## Next Steps After Deployment

1. **Custom Domain**: Add custom domain in Render dashboard
2. **SSL Certificate**: Automatically provisioned by Render
3. **Environment Variables**: Add secrets via Render dashboard
4. **Monitoring**: Set up alerts and notifications
5. **Scaling**: Adjust resources based on traffic
6. **Backup**: Consider backing up any persistent data
7. **Documentation**: Update README with deployment URL

## Additional Resources

- [Render Docker Documentation](https://render.com/docs/docker)
- [http-nu Documentation](https://github.com/cablehead/http-nu)
- [Nushell Documentation](https://www.nushell.sh/)
- [Rust Docker Best Practices](https://docs.docker.com/language/rust/)
