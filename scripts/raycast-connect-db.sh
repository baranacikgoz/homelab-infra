#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Cloudflared Mac Mini DB Tunnel
# @raycast.mode compact
# @raycast.packageName Homelab

# Optional parameters:
# @raycast.icon 🐘

# Documentation:
# @raycast.description Toggles a secure background tunnel to the Mac Mini Postgres DB

# -----------------------------------------------------------------------------
# CONFIGURATION
# -----------------------------------------------------------------------------
# We load credentials from a .env file in the same directory to avoid committing secrets.
#
# 1. Create a file named .env in this script's folder
# 2. Add the following lines to .env:
#    CF_DB_ACCESS_CLIENT_ID="your_client_id"
#    CF_DB_ACCESS_CLIENT_SECRET="your_client_secret"
# -----------------------------------------------------------------------------

HOSTNAME="db.baranacikgoz.com"
LOCAL_PORT="5432"

# Check if already running
PID=$(pgrep -f "cloudflared access tcp --hostname $HOSTNAME")

if [ -n "$PID" ]; then
    kill "$PID"
    echo "🔌 Disconnected (PID: $PID)"
    exit 0
fi

# Resolve the directory where this script resides
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ENV_FILE="$SCRIPT_DIR/.env"

if [ -f "$ENV_FILE" ]; then
    # shellcheck disable=SC1090
    source "$ENV_FILE"
else
    echo "❌ Error: .env file not found"
    exit 1
fi

CLIENT_ID="${CF_DB_ACCESS_CLIENT_ID}"
CLIENT_SECRET="${CF_DB_ACCESS_CLIENT_SECRET}"

if [[ -z "$CLIENT_ID" || -z "$CLIENT_SECRET" ]]; then
   echo "❌ Error: Credentials missing in .env"
   exit 1
fi

# Check if cloudflared is installed
if ! command -v cloudflared &> /dev/null; then
    echo "❌ cloudflared missing"
    exit 1
fi

# Start in background
nohup cloudflared access tcp \
  --hostname "$HOSTNAME" \
  --url "localhost:$LOCAL_PORT" \
  --id "$CLIENT_ID" \
  --secret "$CLIENT_SECRET" > /dev/null 2>&1 &

echo "🚀 TCP Tunnel Connected"
