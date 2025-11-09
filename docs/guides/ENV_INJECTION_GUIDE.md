# Environment Variable Injection Guide

## Overview

This document describes how to securely inject environment variables for different deployment contexts without committing secrets to the repository.

---

## Build-Time Variables

All sensitive configuration must be passed via `--dart-define` at build time, not hardcoded in source files.

### Local Development

Create a `.env` file in the project root (this file is gitignored):

```bash
# .env (DO NOT COMMIT)
APP_FLAVOR=dev
APP_VERSION=dev-local
API_BASE_URL=http://localhost:16110
SENTRY_DSN=
MOCK_MODE=false
```

Run with environment variables:

```bash
# Load .env and build
flutter run -d chrome \
  --dart-define=APP_FLAVOR=dev \
  --dart-define=APP_VERSION=dev-local \
  --dart-define=API_BASE_URL=http://localhost:16110 \
  --dart-define=SENTRY_DSN= \
  --dart-define=MOCK_MODE=false
```

Or use a helper script:

```bash
#!/bin/bash
# run-dev.sh
source .env
flutter run -d chrome \
  --dart-define=APP_FLAVOR=$APP_FLAVOR \
  --dart-define=APP_VERSION=$APP_VERSION \
  --dart-define=API_BASE_URL=$API_BASE_URL \
  --dart-define=SENTRY_DSN=$SENTRY_DSN \
  --dart-define=MOCK_MODE=$MOCK_MODE
```

### Staging Build

```bash
flutter build web \
  --dart-define=APP_FLAVOR=staging \
  --dart-define=APP_VERSION=$(git rev-parse --short HEAD) \
  --dart-define=API_BASE_URL=https://api-staging.appydex.co \
  --dart-define=SENTRY_DSN=https://xxx@sentry.io/staging \
  --release
```

### Production Build

```bash
flutter build web \
  --dart-define=APP_FLAVOR=prod \
  --dart-define=APP_VERSION=1.0.0 \
  --dart-define=API_BASE_URL=https://api.appydex.co \
  --dart-define=SENTRY_DSN=https://yyy@sentry.io/prod \
  --release \
  --web-renderer canvaskit \
  --source-maps
```

---

## CI/CD Secrets

### GitHub Actions

Store secrets in **Settings → Secrets and variables → Actions**:

**Repository Secrets**:
- `STAGING_API_URL`: `https://api-staging.appydex.co`
- `PROD_API_URL`: `https://api.appydex.co`
- `SENTRY_DSN`: Staging Sentry DSN
- `PROD_SENTRY_DSN`: Production Sentry DSN
- `SENTRY_AUTH_TOKEN`: For uploading sourcemaps
- `SENTRY_ORG`: Organization name in Sentry
- `SENTRY_PROJECT`: Project name in Sentry
- `NETLIFY_AUTH_TOKEN`: Netlify deployment token
- `NETLIFY_SITE_ID`: Netlify site identifier
- `CODECOV_TOKEN`: Codecov upload token (optional)

**Environment Secrets** (production environment):
- `PROD_API_URL`
- `PROD_SENTRY_DSN`
- `NETLIFY_AUTH_TOKEN`

Usage in workflow:

```yaml
- name: Build web (production)
  run: |
    flutter build web \
      --dart-define=APP_FLAVOR=prod \
      --dart-define=APP_VERSION=${{ github.ref_name }} \
      --dart-define=API_BASE_URL=${{ secrets.PROD_API_URL }} \
      --dart-define=SENTRY_DSN=${{ secrets.PROD_SENTRY_DSN }} \
      --release
```

### GitLab CI/CD

Store in **Settings → CI/CD → Variables** (protected & masked):

```yaml
# .gitlab-ci.yml
build:prod:
  script:
    - flutter build web \
        --dart-define=APP_FLAVOR=prod \
        --dart-define=APP_VERSION=$CI_COMMIT_TAG \
        --dart-define=API_BASE_URL=$PROD_API_URL \
        --dart-define=SENTRY_DSN=$PROD_SENTRY_DSN \
        --release
```

---

## Hosting Provider Configuration

### Netlify

Environment variables are **not** needed at runtime for Flutter web (all values baked into JS bundle).

But if using Netlify Functions or redirects, configure in:
- **Site settings → Environment variables**

### Vercel

Same as Netlify—Flutter web is fully client-side, no runtime env vars.

Configure build command in `vercel.json`:

```json
{
  "buildCommand": "flutter build web --dart-define=APP_FLAVOR=prod --dart-define=API_BASE_URL=$API_BASE_URL --dart-define=SENTRY_DSN=$SENTRY_DSN --release"
}
```

Then set `API_BASE_URL` and `SENTRY_DSN` in Vercel project settings.

### Firebase Hosting

Store in Firebase environment config:

```bash
firebase functions:config:set \
  app.flavor="prod" \
  app.api_url="https://api.appydex.co" \
  sentry.dsn="https://zzz@sentry.io/prod"
```

---

## Accessing Variables in Code

### Dart Code

```dart
// lib/core/config.dart
const kAppFlavor = String.fromEnvironment('APP_FLAVOR', defaultValue: 'dev');
const kAppVersion = String.fromEnvironment('APP_VERSION', defaultValue: 'unknown');
const kApiBaseUrlDefine = String.fromEnvironment('API_BASE_URL', defaultValue: '');
const kSentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');
const kMockMode = bool.fromEnvironment('MOCK_MODE', defaultValue: false);
```

### Web HTML (if needed)

Flutter web doesn't support runtime env vars. All config must be baked at build time.

If you need runtime config (not recommended), inject via `<script>` in `web/index.html`:

```html
<script>
  window.ENV = {
    API_URL: 'https://api.appydex.co'
  };
</script>
```

Then access in Dart:

```dart
import 'dart:js_util' as js_util;
import 'dart:html' as html;

String getApiUrl() {
  return js_util.getProperty(html.window, 'ENV')['API_URL'];
}
```

**⚠️ Not recommended**: Exposes config in browser source. Use dart-define instead.

---

## Validating Environment Injection

### Pre-Deployment Checklist

- [ ] No secrets in `lib/`, `test/`, or `web/` directories
- [ ] `.env` files are in `.gitignore`
- [ ] All API URLs use `String.fromEnvironment()`
- [ ] Sentry DSN uses `String.fromEnvironment('SENTRY_DSN')`
- [ ] CI/CD secrets are set in protected variables
- [ ] Production builds use `--release` flag
- [ ] Version tracking uses `APP_VERSION` from git tag or commit SHA

### Testing Locally

```bash
# Should fail (no SENTRY_DSN)
flutter build web --dart-define=APP_FLAVOR=prod

# Should succeed
flutter build web \
  --dart-define=APP_FLAVOR=prod \
  --dart-define=API_BASE_URL=https://api.appydex.co \
  --dart-define=SENTRY_DSN=https://test@sentry.io/123 \
  --dart-define=APP_VERSION=1.0.0 \
  --release
```

### Verify Build Output

After building, check that secrets are **not** exposed:

```bash
# Search for hardcoded secrets in JS bundle
grep -r "sk_live_" build/web/
grep -r "Bearer eyJ" build/web/

# Should return nothing
```

---

## Secret Rotation

When rotating secrets (API keys, Sentry DSN):

1. Update in CI/CD secrets
2. Rebuild and redeploy all environments
3. Revoke old secrets after 24-48 hours

---

## .env.example Template

Create `.env.example` (committed to repo) as a template:

```bash
# .env.example
# Copy to .env and fill in actual values (DO NOT COMMIT .env)

APP_FLAVOR=dev
APP_VERSION=dev-local
API_BASE_URL=http://localhost:16110
SENTRY_DSN=
MOCK_MODE=false
```

---

## Troubleshooting

### Build fails with "Invalid prod API_BASE_URL"

Ensure you pass `--dart-define=API_BASE_URL=https://...` with HTTPS in prod flavor.

### Sentry not capturing errors

Check:
1. `SENTRY_DSN` is passed at build time
2. DSN is not empty string
3. Sentry is initialized in `main()`

### API requests fail with CORS error

Ensure:
1. Backend CORS allows the exact origin (e.g., `https://admin.appydex.com`)
2. `Access-Control-Allow-Credentials: true` is set
3. Frontend `withCredentials` is enabled in `api_client.dart`

---

## Security Best Practices

1. **Never commit** `.env`, `.env.local`, `.env.prod` files
2. **Use protected branches** to require CI checks before merge
3. **Rotate secrets** every 90 days
4. **Audit access logs** for secret retrieval in CI/CD
5. **Limit secret scope**: Use different tokens for staging vs. production

---

## References

- [Flutter Environment Variables](https://docs.flutter.dev/deployment/flavors)
- [GitHub Actions Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Netlify Environment Variables](https://docs.netlify.com/configure-builds/environment-variables/)
- [OWASP Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
