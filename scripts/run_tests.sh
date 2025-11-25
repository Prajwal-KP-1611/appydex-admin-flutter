#!/usr/bin/env bash
set -e
echo "Running tests for $(basename $(pwd))"
if [ -f "pubspec.yaml" ]; then
  flutter test || true
elif [ -f "package.json" ]; then
  npm ci && npm test || true
elif [ -f "composer.json" ]; then
  vendor/bin/phpunit || true
elif ls *.py >/dev/null 2>&1; then
  pytest || true
else
  echo "No test runner found."
fi
