#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Connect AI Gateway (LiteLLM)
# @raycast.mode compact
# @raycast.packageName Homelab

# Optional parameters:
# @raycast.icon 🧠

# Documentation:
# @raycast.description Toggles a secure SSH background tunnel to the Mac Mini LiteLLM gateway, securely bypassing Cloudflare Access.

# -----------------------------------------------------------------------------
# CONFIGURATION
# -----------------------------------------------------------------------------
# This script uses your local SSH configuration to connect to 'macserver'.
# It bridges port 4000 on your Macbook Air directly to the internal Kubernetes 
# ClusterIP of LiteLLM, bypassing the public Cloudflare Edge entirely.
# -----------------------------------------------------------------------------

HOSTNAME="macserver"
LOCAL_PORT="4000"
REMOTE_PORT="4000"

# Check if already running by looking for port ownership
PID=$(lsof -ti :$LOCAL_PORT)

if [ -n "$PID" ]; then
    kill "$PID"
    # Wait a moment for the port to be released
    sleep 1
    echo "🔌 AI Gateway Disconnected (PID: $PID)"
    exit 0
fi

# Fetch the Litellm Cluster IP dynamically
CLUSTER_IP=$(ssh "$HOSTNAME" "kubectl get svc -n litellm litellm -o jsonpath='{.spec.clusterIP}'" 2>/dev/null)

if [ -z "$CLUSTER_IP" ]; then
    echo "❌ Error: Could not query Kubernetes for LiteLLM IP via $HOSTNAME."
    exit 1
fi

# Start the SSH tunnel in the background with keep-alive
nohup ssh -N \
  -o "ServerAliveInterval 30" \
  -o "ServerAliveCountMax 3" \
  -o "ExitOnForwardFailure yes" \
  -L "$LOCAL_PORT:$CLUSTER_IP:$REMOTE_PORT" "$HOSTNAME" > /dev/null 2>&1 &

# Verify if the port is now being listened on
sleep 2
if lsof -Pi :$LOCAL_PORT -sTCP:LISTEN -t >/dev/null; then
    echo "🚀 Connected: http://localhost:$LOCAL_PORT"
else
    echo "❌ Error: Tunnel failed to bind to port $LOCAL_PORT."
    exit 1
fi
