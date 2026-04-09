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

# Check if already running by aggressively matching our specific tunnel pattern
# (We match the SSH command signature that forwards to port 4000 on the host)
PID=$(pgrep -f "ssh -N -L $LOCAL_PORT:.*:$REMOTE_PORT $HOSTNAME")

if [ -n "$PID" ]; then
    kill "$PID"
    echo "🔌 AI Gateway Disconnected (PID: $PID)"
    exit 0
fi

# Fetch the Litellm Cluster IP dynamically in case the service was recreated
CLUSTER_IP=$(ssh "$HOSTNAME" "kubectl get svc -n litellm litellm -o jsonpath='{.spec.clusterIP}'" 2>/dev/null)

if [ -z "$CLUSTER_IP" ]; then
    echo "❌ Error: Could not query Kubernetes for LiteLLM IP via $HOSTNAME."
    exit 1
fi

# Start the SSH tunnel in the background with keep-alive to prevent drops
nohup ssh -N \
  -o "ServerAliveInterval 30" \
  -o "ServerAliveCountMax 3" \
  -o "ExitOnForwardFailure yes" \
  -L "$LOCAL_PORT:$CLUSTER_IP:$REMOTE_PORT" "$HOSTNAME" > /dev/null 2>&1 &

# Brief pause to verify if it spawned correctly
sleep 1
NEW_PID=$(pgrep -f "ssh -N -L $LOCAL_PORT:$CLUSTER_IP:$REMOTE_PORT $HOSTNAME")

if [ -n "$NEW_PID" ]; then
    echo "🚀 Connected: http://localhost:$LOCAL_PORT (Bypassing Cloudflare)"
else
    echo "❌ Error: Failed to start SSH tunnel process."
    exit 1
fi
