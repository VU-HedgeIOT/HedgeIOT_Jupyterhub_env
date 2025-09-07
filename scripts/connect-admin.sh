#!/bin/bash
# Helper script to connect to JupyterHub admin container

set -e

echo "🔍 Finding JupyterHub admin container..."

# Find the admin container
ADMIN_CONTAINER=$(docker ps --filter "name=jupyter-admin" --format "{{.Names}}" | head -1)

if [ -z "$ADMIN_CONTAINER" ]; then
    echo "❌ No JupyterHub admin container found!"
    echo "   Make sure you're logged in as admin user and server is running"
    exit 1
fi

echo "✅ Found container: $ADMIN_CONTAINER"

# Get container IP
CONTAINER_IP=$(docker inspect $ADMIN_CONTAINER --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')

if [ -z "$CONTAINER_IP" ]; then
    echo "❌ Could not get container IP"
    exit 1
fi

echo "🌐 Container IP: $CONTAINER_IP"

# Check if SSH daemon is running
echo "🔍 Checking SSH daemon..."
if ! docker exec $ADMIN_CONTAINER pgrep sshd > /dev/null 2>&1; then
    echo "🔧 Starting SSH daemon..."
    docker exec $ADMIN_CONTAINER sudo /usr/sbin/sshd
fi

# Check SSH port
SSH_PORT=$(docker port $ADMIN_CONTAINER 22/tcp 2>/dev/null | cut -d: -f2 || echo "")

# Determine connection method
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SSH_KEY="$PROJECT_DIR/.ssh/jupyterlab-admin"

if [ ! -f "$SSH_KEY" ]; then
    echo "❌ SSH key not found: $SSH_KEY"
    echo "   Run ./scripts/setup-admin-ssh.sh first"
    exit 1
fi

echo ""
echo "🚀 Connecting to admin container..."
echo "   Container: $ADMIN_CONTAINER"
echo "   IP: $CONTAINER_IP"
if [ -n "$SSH_PORT" ]; then
    echo "   External port: $SSH_PORT"
    ssh -i "$SSH_KEY" -p "$SSH_PORT" -o StrictHostKeyChecking=no jovyan@localhost
else
    echo "   Using internal IP (no external port)"
    ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no jovyan@"$CONTAINER_IP"
fi
