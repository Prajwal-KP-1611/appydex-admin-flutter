#!/bin/bash
# Quick launch script for AppyDex Admin Panel
# Runs Flutter web on localhost:46633

echo "🚀 Starting AppyDex Admin Panel on http://localhost:46633"
echo ""

flutter run -d chrome --web-port=46633 --web-hostname=localhost
