# Security Headers Configuration

## Production Deployment Requirements

This document outlines the required security headers and cookie configurations for production deployment of the AppyDex Admin web application.

---

## HTTP Security Headers

### Content Security Policy (CSP)

Add the following CSP header to your web server or hosting configuration:

```
Content-Security-Policy: 
  default-src 'self';
  script-src 'self' 'wasm-unsafe-eval';
  style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
  font-src 'self' https://fonts.gstatic.com;
  img-src 'self' data: https:;
  connect-src 'self' https://api.appydex.co https://sentry.io;
  frame-ancestors 'none';
  base-uri 'self';
  form-action 'self';
```

**Note**: The `wasm-unsafe-eval` directive is required for Flutter's CanvasKit renderer.

### HTTP Strict Transport Security (HSTS)

```
Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
```

Enforces HTTPS for the domain and all subdomains for 1 year.

### X-Frame-Options

```
X-Frame-Options: DENY
```

Prevents the admin panel from being embedded in iframes (clickjacking protection).

### X-Content-Type-Options

```
X-Content-Type-Options: nosniff
```

Prevents MIME type sniffing.

### Referrer-Policy

```
Referrer-Policy: strict-origin-when-cross-origin
```

Controls referrer information sent with requests.

### Permissions-Policy

```
Permissions-Policy: 
  geolocation=(),
  microphone=(),
  camera=(),
  payment=(),
  usb=()
```

Disables unnecessary browser features.

---

## Cookie Configuration

### Refresh Token Cookie (Backend)

The backend must set the refresh token as an HttpOnly cookie with these flags:

```http
Set-Cookie: admin_refresh_token=<jwt>;
  Path=/api/v1/admin/auth;
  HttpOnly;
  Secure;
  SameSite=Strict;
  Max-Age=604800
```

**Properties**:
- `HttpOnly`: Prevents JavaScript access (XSS mitigation)
- `Secure`: Only sent over HTTPS
- `SameSite=Strict`: Prevents CSRF attacks
- `Max-Age=604800`: 7 days expiration

### Session Cookie (if used)

```http
Set-Cookie: admin_session=<session_id>;
  Path=/;
  HttpOnly;
  Secure;
  SameSite=Strict;
  Max-Age=86400
```

---

## CORS Configuration (Backend)

The backend API must be configured with:

```yaml
Access-Control-Allow-Origin: https://admin.appydex.com
Access-Control-Allow-Credentials: true
Access-Control-Allow-Headers: Authorization, Content-Type, X-Trace-Id, Idempotency-Key, X-API-Version
Access-Control-Allow-Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS
Access-Control-Max-Age: 86400
```

**Important**:
- `Access-Control-Allow-Origin` must be the **exact origin** (not `*`) when using credentials
- `Access-Control-Allow-Credentials: true` is required for cookie-based authentication

---

## Server Configuration Examples

### Nginx

```nginx
server {
    listen 443 ssl http2;
    server_name admin.appydex.com;

    # SSL configuration
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Permissions-Policy "geolocation=(), microphone=(), camera=(), payment=(), usb=()" always;
    
    # CSP header
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'wasm-unsafe-eval'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: https:; connect-src 'self' https://api.appydex.co https://sentry.io; frame-ancestors 'none'; base-uri 'self'; form-action 'self';" always;

    root /var/www/admin/build/web;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

### Netlify

Create `netlify.toml` in the project root:

```toml
[[headers]]
  for = "/*"
  [headers.values]
    Strict-Transport-Security = "max-age=31536000; includeSubDomains; preload"
    X-Frame-Options = "DENY"
    X-Content-Type-Options = "nosniff"
    Referrer-Policy = "strict-origin-when-cross-origin"
    Permissions-Policy = "geolocation=(), microphone=(), camera=(), payment=(), usb=()"
    Content-Security-Policy = "default-src 'self'; script-src 'self' 'wasm-unsafe-eval'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: https:; connect-src 'self' https://api.appydex.co https://sentry.io; frame-ancestors 'none'; base-uri 'self'; form-action 'self';"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

### Vercel

Create `vercel.json` in the project root:

```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "Strict-Transport-Security",
          "value": "max-age=31536000; includeSubDomains; preload"
        },
        {
          "key": "X-Frame-Options",
          "value": "DENY"
        },
        {
          "key": "X-Content-Type-Options",
          "value": "nosniff"
        },
        {
          "key": "Referrer-Policy",
          "value": "strict-origin-when-cross-origin"
        },
        {
          "key": "Permissions-Policy",
          "value": "geolocation=(), microphone=(), camera=(), payment=(), usb=()"
        },
        {
          "key": "Content-Security-Policy",
          "value": "default-src 'self'; script-src 'self' 'wasm-unsafe-eval'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com; img-src 'self' data: https:; connect-src 'self' https://api.appydex.co https://sentry.io; frame-ancestors 'none'; base-uri 'self'; form-action 'self';"
        }
      ]
    }
  ],
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
```

---

## Environment Variables

### Required Build-Time Variables

Pass these via `--dart-define` during build:

```bash
flutter build web \
  --dart-define=APP_FLAVOR=prod \
  --dart-define=APP_VERSION=1.0.0 \
  --dart-define=API_BASE_URL=https://api.appydex.co \
  --dart-define=SENTRY_DSN=https://xxx@sentry.io/yyy \
  --release
```

### CI/CD Secrets

Store these in your CI/CD environment (GitHub Actions, GitLab CI, etc.):

- `PROD_API_URL`: Production API base URL
- `STAGING_API_URL`: Staging API base URL
- `SENTRY_DSN`: Sentry DSN for error reporting
- `PROD_SENTRY_DSN`: Production Sentry DSN
- `SENTRY_AUTH_TOKEN`: Sentry authentication token (for sourcemap uploads)
- `SENTRY_ORG`: Sentry organization name
- `SENTRY_PROJECT`: Sentry project name
- `NETLIFY_AUTH_TOKEN` / `VERCEL_TOKEN`: Hosting provider credentials

**Never commit secrets to the repository.**

---

## Testing Security Headers

After deployment, verify headers using:

```bash
curl -I https://admin.appydex.com
```

Or use online tools:
- [Security Headers](https://securityheaders.com/)
- [Mozilla Observatory](https://observatory.mozilla.org/)

---

## XSS Mitigation Strategy

1. **HttpOnly Cookies**: Refresh tokens stored as HttpOnly cookies (not accessible via JavaScript)
2. **CSP**: Blocks inline scripts and restricts resource origins
3. **Input Validation**: All user inputs sanitized on backend
4. **Output Encoding**: Flutter automatically escapes text in widgets
5. **CORS**: Strict origin validation prevents unauthorized API access

---

## Backend Coordination Required

The backend team must implement:

1. **Refresh Token Cookie**: Set `admin_refresh_token` as HttpOnly cookie on `/auth/login` and `/auth/refresh`
2. **CORS Headers**: Enable credentials and whitelist exact admin panel origin
3. **OPTIONS Preflight**: Return proper CORS headers for preflight requests
4. **Cookie Path**: Restrict cookie path to `/api/v1/admin/auth` to minimize attack surface

Backend ticket: `docs/tickets/BACKEND_HTTPONLY_COOKIE_REFRESH.md`

---

## Monitoring

Sentry will capture:
- CSP violations
- HTTP errors (4xx, 5xx)
- JavaScript exceptions
- Performance issues

Review Sentry dashboard regularly for security anomalies.

---

## Compliance Notes

- **GDPR**: Session cookies require user consent if tracking is enabled
- **OWASP Top 10**: This configuration addresses A5 (Security Misconfiguration) and A7 (XSS)
- **PCI-DSS**: HSTS and secure cookies required if processing payments

---

## References

- [OWASP Secure Headers Project](https://owasp.org/www-project-secure-headers/)
- [MDN: Content-Security-Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
- [MDN: Set-Cookie](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie)
