# Web Security Configuration

## Required Reverse Proxy Headers

Configure your reverse proxy (Nginx, Apache, or CDN) to send these security headers for the admin dashboard:

### Content Security Policy (CSP)
```
Content-Security-Policy: default-src 'self'; script-src 'self' 'wasm-unsafe-eval' 'unsafe-inline' https://www.gstatic.com; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; connect-src 'self' https://api.appydex.com https://www.gstatic.com; worker-src 'self' blob:; frame-ancestors 'none'; base-uri 'self'
```

**Important Notes:**
- `script-src` includes `'unsafe-inline'` for Flutter DevTools in development
- `script-src` includes `https://www.gstatic.com` for Flutter CanvasKit
- `connect-src` includes `https://www.gstatic.com` for CanvasKit WASM files
- `worker-src 'self' blob:` needed for Flutter Web Workers
- `frame-ancestors 'none'` can only be set via server headers (not meta tag)
- Adjust `connect-src` to include your actual API domain

**Production CSP (more restrictive):**
For production builds, you can be more restrictive since DevTools won't be used:
```
Content-Security-Policy: default-src 'self'; script-src 'self' 'wasm-unsafe-eval' https://www.gstatic.com; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; connect-src 'self' https://api.appydex.com https://www.gstatic.com; worker-src 'self' blob:; frame-ancestors 'none'; base-uri 'self'
```

**Note:** Adjust `connect-src` to include your actual API domain (e.g., `https://api.appydex.com` or `https://api.appydex.co`).

### Other Security Headers
```
Referrer-Policy: strict-origin-when-cross-origin
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
X-XSS-Protection: 1; mode=block
```

### Cache Control for API Routes

**IMPORTANT:** Disable caching for authenticated API responses:

```
# For /admin/* API endpoints
Cache-Control: no-store, no-cache, must-revalidate, private
Pragma: no-cache
Expires: 0
```

## Example Nginx Configuration

```nginx
server {
    listen 443 ssl http2;
    server_name admin.appydex.com;

    # SSL configuration
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    # Security headers
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'wasm-unsafe-eval' https://www.gstatic.com; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; connect-src 'self' https://api.appydex.com https://www.gstatic.com; worker-src 'self' blob:; frame-ancestors 'none'; base-uri 'self'" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Serve Flutter web app
    location / {
        root /var/www/appydex-admin/build/web;
        try_files $uri $uri/ /index.html;
        
        # Cache static assets
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }

    # Proxy API requests
    location /api/ {
        proxy_pass https://api.appydex.com;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Disable caching for API
        add_header Cache-Control "no-store, no-cache, must-revalidate, private" always;
        add_header Pragma "no-cache" always;
        expires -1;
    }
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name admin.appydex.com;
    return 301 https://$server_name$request_uri;
}
```

## Service Worker Scope

If using a service worker, ensure it does NOT cache API responses. Scope the service worker to static assets only:

```javascript
// In flutter_service_worker.js or sw.js
const CACHE_NAME = 'appydex-admin-static-v1';

// Only cache static assets
const urlsToCache = [
  '/',
  '/index.html',
  '/manifest.json',
  '/favicon.png',
  // Add other static assets
];

// Do NOT cache /api/* or authenticated routes
self.addEventListener('fetch', (event) => {
  if (event.request.url.includes('/api/') || 
      event.request.url.includes('api.appydex.com')) {
    return; // Don't cache API requests
  }
  
  // Cache other requests
  event.respondWith(
    caches.match(event.request).then((response) => {
      return response || fetch(event.request);
    })
  );
});
```

## Production Checklist

- [ ] CSP headers configured and tested
- [ ] HSTS enabled with preload
- [ ] API responses have `Cache-Control: no-store`
- [ ] Service worker (if any) doesn't cache API calls
- [ ] SSL/TLS certificate valid and up to date
- [ ] Test with [securityheaders.com](https://securityheaders.com)
- [ ] Test CSP doesn't block necessary resources
- [ ] Verify frame-ancestors prevents clickjacking

## Testing

Test your security headers:
1. https://securityheaders.com
2. https://observatory.mozilla.org
3. Browser DevTools Network tab (check headers)

Check CSP violations in browser console during manual testing.
