# CSP Configuration Guide

## Overview
Content Security Policy (CSP) has been configured for development and production environments.

## Files
- `web/index.html` - Development CSP (includes localhost for local backend testing)
- `web/index.production.html` - Production CSP (no localhost URLs)

## Development CSP
The development CSP in `web/index.html` includes:
- `http://localhost:16110` for local API testing
- `ws://localhost:*` and `ws://127.0.0.1:*` for local WebSocket/hot reload

## Production CSP
The production CSP in `web/index.production.html` removes all localhost URLs and only allows:
- `https://api.appydex.com`
- `https://api.appydex.co`
- Google Fonts and related resources

## Recommended Approach
**Best Practice:** Set CSP via reverse proxy headers instead of HTML meta tags for:
- Better flexibility per environment
- Runtime configuration without rebuilding
- Stronger security (meta tags can be modified client-side)

### Example Nginx Configuration
```nginx
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'wasm-unsafe-eval' 'unsafe-inline' https://www.gstatic.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: https:; connect-src 'self' https://api.appydex.co https://www.gstatic.com https://fonts.gstatic.com https://fonts.googleapis.com; worker-src 'self' blob:; base-uri 'self'" always;
```

### Example Apache Configuration
```apache
Header always set Content-Security-Policy "default-src 'self'; script-src 'self' 'wasm-unsafe-eval' 'unsafe-inline' https://www.gstatic.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: https:; connect-src 'self' https://api.appydex.co https://www.gstatic.com https://fonts.gstatic.com https://fonts.googleapis.com; worker-src 'self' blob:; base-uri 'self'"
```

## Build Instructions
For production builds, use the production HTML file:
```bash
# Option 1: Copy production HTML before build
cp web/index.production.html web/index.html
flutter build web --release

# Option 2: Use build flavor/configuration to swap files
# (Requires custom build script)
```

## Notes
- CSP in meta tags is a fallback; always prefer server-side headers.
- `frame-ancestors` directive cannot be set via meta tag and must be set by server.
- For staging environments, create a separate `index.staging.html` with staging API URLs.
