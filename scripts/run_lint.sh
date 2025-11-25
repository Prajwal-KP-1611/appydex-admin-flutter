#!/usr/bin/env bash
set -e
echo "Running lint for $(basename $(pwd))"
if [ -f "pubspec.yaml" ]; then
  flutter analyze || true
elif [ -f "package.json" ]; then
  npm run lint || true
elif [ -f "composer.json" ]; then
  vendor/bin/phpcs || true
else
  echo "No linter configured."
fi
