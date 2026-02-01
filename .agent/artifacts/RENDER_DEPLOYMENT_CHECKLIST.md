# Render.com Deployment Checklist

## ✅ Pre-Deployment Checklist

### 1. Required Files in Repository

- [ ] `Dockerfile` - Multi-stage Docker build configuration
- [ ] `serve.nu` - Production handler with all examples mounted
- [ ] `render.yaml` - Render.com service configuration (this file)
- [ ] `.dockerignore` - Build context optimization
- [ ] `examples/` directory with all example handlers
- [ ] `Cargo.toml` and `Cargo.lock` - Rust dependencies

### 2. Configuration Updates

- [ ] Update `render.yaml` with your GitHub repository URL
  ```yaml
  repo: https://github.com/YOUR_USERNAME/http-nu
  ```
- [ ] Verify `serve.nu` includes all example routes
- [ ] Confirm `Dockerfile` copies examples directory
- [ ] Check `.dockerignore` doesn't exclude examples

### 3. Local Testing

- [ ] Build Docker image locally:
  ```bash
  docker build -t http-nu:test .
  ```
- [ ] Run container with store:
  ```bash
  docker run -p 3001:3001 -e PORT=3001 -v http-nu-store:/data http-nu:test
  ```
- [ ] Test all endpoints:
  - [ ] `curl http://localhost:3001/` (Landing page)
  - [ ] `curl http://localhost:3001/health` (Health check)
  - [ ] `curl http://localhost:3001/examples/basic`
  - [ ] `curl http://localhost:3001/examples/quotes`
  - [ ] `curl http://localhost:3001/examples/datastar`
  - [ ] `curl http://localhost:3001/examples/datastar-test`
  - [ ] `curl http://localhost:3001/examples/templates`

## 🚀 Deployment Steps

### Step 1: Prepare Repository

```bash
# Ensure all files are committed
git add Dockerfile serve.nu render.yaml .dockerignore
git commit -m "feat: add Render.com deployment configuration"
git push origin main
```

### Step 2: Create Render Blueprint

1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click **"New"** → **"Blueprint"**
3. Connect your GitHub account (if not already connected)
4. Select your `http-nu` repository
5. Click **"Connect"**

### Step 3: Configure Blueprint

1. **Blueprint Name**: `http-nu` (or your preferred name)
2. **Branch**: `main` (or your deployment branch)
3. Review the service configuration from `render.yaml`
4. Verify:
   - Service type: **Web Service**
   - Runtime: **Docker**
   - Plan: **Starter** ($7/month)
   - Disk: **1GB** at `/data`
   - Environment variables: `LOG_FORMAT=jsonl`, `RUST_LOG=info`

### Step 4: Deploy

1. Click **"Apply"** to create the Blueprint
2. Render will:
   - Clone your repository
   - Build the Docker image (5-10 minutes)
   - Deploy the container
   - Run health checks
   - Assign a public URL

### Step 5: Monitor Deployment

1. Watch the build logs in real-time
2. Look for:
   - ✅ Docker build successful
   - ✅ Image pushed to registry
   - ✅ Container started
   - ✅ Health check passing
3. Common issues:
   - Build timeout: Image too large or slow build
   - Health check failing: `/health` endpoint not responding
   - Container crash: Check logs for errors

## 🧪 Post-Deployment Validation

### 1. Test All Endpoints

Your service will be available at: `https://http-nu.onrender.com` (or similar)

```bash
# Set your Render URL
RENDER_URL="https://http-nu.onrender.com"

# Test landing page
curl $RENDER_URL/

# Test health check
curl $RENDER_URL/health

# Test examples
curl $RENDER_URL/examples/basic
curl $RENDER_URL/examples/quotes
curl $RENDER_URL/examples/datastar
curl $RENDER_URL/examples/datastar-test
curl $RENDER_URL/examples/templates
```

### 2. Verify Store Persistence

```bash
# Post a quote
curl -X POST $RENDER_URL/examples/quotes \
  -H "Content-Type: application/json" \
  -d '{"quote": "Test quote", "who": "Test User"}'

# Verify it appears
curl $RENDER_URL/examples/quotes
```

### 3. Check Logs

1. Go to your service in Render Dashboard
2. Click **"Logs"** tab
3. Verify:
   - JSON-formatted logs (`LOG_FORMAT=jsonl`)
   - No error messages
   - Request logs appearing

### 4. Monitor Metrics

1. Check **"Metrics"** tab in Render Dashboard
2. Monitor:
   - CPU usage (should be low at idle)
   - Memory usage (should be < 256MB)
   - Request count
   - Response times

## 🔧 Configuration Options

### Change Instance Plan

Edit `render.yaml`:
```yaml
plan: free      # Free tier (sleeps after 15min)
plan: starter   # $7/month (always on)
plan: standard  # $25/month (more resources)
```

### Change Region

Edit `render.yaml`:
```yaml
region: oregon      # US West
region: frankfurt   # Europe
region: singapore   # Asia
region: ohio        # US East
region: virginia    # US East
```

### Adjust Disk Size

Edit `render.yaml`:
```yaml
disk:
  sizeGB: 1   # Minimum
  sizeGB: 10  # More storage
```

### Add Environment Variables

Edit `render.yaml`:
```yaml
envVars:
  - key: CUSTOM_VAR
    value: custom_value
```

## 🔄 Auto-Deploy

Every push to `main` that modifies these files will trigger a rebuild:
- `src/**`
- `examples/**`
- `Cargo.toml`, `Cargo.lock`
- `Dockerfile`
- `serve.nu`
- `build.rs`
- `syntaxes/**`

To disable auto-deploy:
1. Go to Blueprint settings in Render Dashboard
2. Set **"Auto Sync"** to **"No"**
3. Manually trigger deploys with **"Manual Sync"**

## 🐛 Troubleshooting

### Build Fails

**Issue**: Docker build times out or fails

**Solutions**:
- Check Dockerfile syntax
- Verify all COPY paths exist
- Review build logs for specific errors
- Ensure dependencies are in Cargo.toml

### Health Check Fails

**Issue**: Service deployed but health check failing

**Solutions**:
- Verify `/health` endpoint in serve.nu
- Check PORT binding: `http-nu :${PORT}`
- Review container logs
- Test locally with same PORT

### Container Crashes

**Issue**: Container starts then immediately stops

**Solutions**:
- Check logs for panic/error messages
- Verify serve.nu syntax
- Test examples locally
- Ensure store path is writable

### Examples Not Working

**Issue**: Landing page works but examples return 404

**Solutions**:
- Verify examples/ directory copied in Dockerfile
- Check route patterns in serve.nu
- Test path stripping logic
- Review logs for routing errors

### Store Not Persisting

**Issue**: Quotes example doesn't persist data

**Solutions**:
- Verify disk mount in render.yaml
- Check `--store /data/store` flag in CMD
- Ensure disk path is writable
- Review store initialization logs

## 📊 Success Metrics

After deployment, you should see:

- ✅ **Build Time**: < 10 minutes
- ✅ **Image Size**: < 100MB
- ✅ **Cold Start**: < 30 seconds
- ✅ **Health Check**: Passing (200 OK)
- ✅ **Memory Usage**: < 256MB
- ✅ **All Examples**: Accessible and functional
- ✅ **Logs**: JSON-formatted, no errors
- ✅ **Auto-Deploy**: Working on git push

## 🎉 You're Done!

Your http-nu service is now deployed with all examples accessible at:

- **Landing**: `https://your-app.onrender.com/`
- **Basic**: `https://your-app.onrender.com/examples/basic`
- **Quotes**: `https://your-app.onrender.com/examples/quotes`
- **Datastar**: `https://your-app.onrender.com/examples/datastar`
- **Datastar Test**: `https://your-app.onrender.com/examples/datastar-test`
- **Templates**: `https://your-app.onrender.com/examples/templates`

## 📚 Next Steps

- [ ] Add custom domain (optional)
- [ ] Set up monitoring/alerts
- [ ] Configure SSL certificate (automatic)
- [ ] Add more examples
- [ ] Optimize performance
- [ ] Set up staging environment

## 📞 Support

- [Render Documentation](https://render.com/docs)
- [Render Community](https://community.render.com)
- [http-nu GitHub](https://github.com/cablehead/http-nu)
- [Render Status](https://status.render.com)

---

**Last Updated**: 2026-01-31  
**Version**: 1.0  
**Status**: Production Ready ✅
