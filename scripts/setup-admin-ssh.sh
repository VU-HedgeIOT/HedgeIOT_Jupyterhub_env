#!/bin/bash
# Setup script for admin SSH access to JupyterLab container

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SSH_DIR="$PROJECT_DIR/.ssh"
KEY_NAME="jupyterlab-admin"

echo "🔧 Setting up SSH access for JupyterLab Admin container..."

# Create SSH directory if it doesn't exist
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Generate SSH key pair if it doesn't exist
if [[ ! -f "$SSH_DIR/$KEY_NAME" ]]; then
    echo "🔑 Generating SSH key pair..."
    ssh-keygen -t ed25519 -f "$SSH_DIR/$KEY_NAME" -N "" -C "jupyterlab-admin@$(hostname)"
    echo "✅ SSH key pair generated at $SSH_DIR/$KEY_NAME"
else
    echo "🔑 SSH key pair already exists at $SSH_DIR/$KEY_NAME"
fi

# Create authorized_keys file
echo "📝 Setting up authorized_keys..."
cp "$SSH_DIR/$KEY_NAME.pub" "$SSH_DIR/authorized_keys"
chmod 600 "$SSH_DIR/authorized_keys"

# Create SSH config for easy connection
cat > "$SSH_DIR/config" << EOF
Host jupyterlab-admin
    HostName localhost
    Port 2222
    User jovyan
    IdentityFile $SSH_DIR/$KEY_NAME
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    LogLevel QUIET
EOF

chmod 600 "$SSH_DIR/config"

echo ""
echo "🎉 SSH setup complete!"
echo ""
echo "📋 Connection Information:"
echo "   SSH Key: $SSH_DIR/$KEY_NAME"
echo "   Public Key: $SSH_DIR/$KEY_NAME.pub"
echo "   SSH Config: $SSH_DIR/config"
echo ""
echo "🚀 Usage:"
echo "   1. Start the admin container: docker compose up -d jupyterlab-admin"
echo "   2. Connect via SSH: ssh -F $SSH_DIR/config jupyterlab-admin"
echo "   3. Or connect with Cursor: Use 'localhost:2222' with key $SSH_DIR/$KEY_NAME"
echo ""
echo "🔐 Security Notes:"
echo "   - SSH password authentication is DISABLED"
echo "   - Only key-based authentication is allowed"
echo "   - User 'jovyan' has passwordless sudo access"
echo "   - Root login is DISABLED"
