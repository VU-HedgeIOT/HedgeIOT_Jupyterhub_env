# SSH Configuration for Local Machine

To connect to the JupyterLab Admin container from your local machine using Cursor, add this to your **local machine's** `~/.ssh/config`:

## Option 1: Direct Port Forwarding

```ssh-config
# Existing configuration (keep as-is)
Host vud
    HostName ssh.data.vu.nl
    User mka299

Host hedgeiot
    HostName 130.37.53.67
    User mka299
    ProxyJump vud
    ForwardAgent yes

# NEW: JupyterLab Admin Container Access
Host jupyterlab-admin-remote
    HostName localhost
    Port 2223
    User jovyan
    IdentityFile /path/to/your/local/jupyterlab-admin-key
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    LogLevel QUIET

# NEW: Port forwarding tunnel
Host hedgeiot-tunnel
    HostName 130.37.53.67
    User mka299
    ProxyJump vud
    ForwardAgent yes
    LocalForward 2223 localhost:2222
    ExitOnForwardFailure yes
```

## Option 2: Combined Connection (Recommended)

```ssh-config
# Existing configuration (keep as-is)
Host vud
    HostName ssh.data.vu.nl
    User mka299

# UPDATED: Add port forwarding to existing hedgeiot config
Host hedgeiot
    HostName 130.37.53.67
    User mka299
    ProxyJump vud
    ForwardAgent yes
    LocalForward 2223 localhost:2222

# NEW: Direct admin container access
Host jupyterlab-admin
    HostName localhost
    Port 2223
    User jovyan
    IdentityFile ~/.ssh/jupyterlab-admin
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
```

## Setup Steps

### 1. Copy SSH Key to Local Machine

From the remote host (where you are now), copy the SSH key:

```bash
# Display the private key (copy this content)
cat .ssh/jupyterlab-admin

# Display the public key (copy this content too)
cat .ssh/jupyterlab-admin.pub
```

### 2. Create SSH Key on Local Machine

On your **local machine**:

```bash
# Create .ssh directory if it doesn't exist
mkdir -p ~/.ssh

# Create the private key file
cat > ~/.ssh/jupyterlab-admin << 'EOF'
[PASTE PRIVATE KEY CONTENT HERE]
EOF

# Create the public key file
cat > ~/.ssh/jupyterlab-admin.pub << 'EOF'
[PASTE PUBLIC KEY CONTENT HERE]
EOF

# Set correct permissions
chmod 600 ~/.ssh/jupyterlab-admin
chmod 644 ~/.ssh/jupyterlab-admin.pub
```

### 3. Update SSH Config on Local Machine

Add one of the configurations above to your `~/.ssh/config` on your local machine.

## Usage

### Method 1: Two-Step Connection

```bash
# Step 1: Establish tunnel (from local machine)
ssh hedgeiot-tunnel

# Step 2: In another terminal, connect to admin container
ssh jupyterlab-admin-remote
```

### Method 2: Combined Connection (Recommended)

```bash
# Step 1: Connect to hedgeiot (establishes port forward automatically)
ssh hedgeiot

# Step 2: In another terminal on local machine, connect to admin container
ssh jupyterlab-admin
```

## Cursor IDE Setup

1. **Open Cursor**
2. **Command Palette** (`Ctrl+Shift+P` / `Cmd+Shift+P`)
3. **"Remote-SSH: Connect to Host"**
4. **Select**: `jupyterlab-admin` (after establishing tunnel)
5. **Working Directory**: `/home/jovyan/project`

## Verification

Test the connection from your local machine:

```bash
# After establishing the tunnel, test connection
ssh jupyterlab-admin 'echo "Connected from local machine!" && hostname && pwd'
```

## Troubleshooting

### Port Already in Use
If port 2223 is busy on your local machine:
- Change `2223` to another port (e.g., `2224`) in both LocalForward and the admin host config

### Connection Refused
- Ensure the admin container is running: `ssh hedgeiot "docker compose --profile admin ps"`
- Check port forwarding: `ssh hedgeiot "netstat -tlnp | grep 2222"`

### Permission Denied
- Verify key permissions: `ls -la ~/.ssh/jupyterlab-admin`
- Should be: `-rw------- 1 user user 419 date ~/.ssh/jupyterlab-admin`
