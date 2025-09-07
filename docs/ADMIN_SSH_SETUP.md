# Admin SSH Access Setup

Simple SSH access to JupyterHub admin containers for remote development with Cursor/VS Code.

## How It Works

When admin users log into JupyterHub:
- **Auto-spawns** `custom-jupyterlab-admin:latest` image
- **SSH server** runs automatically  
- **Bash profile** shows connection info when terminal opens
- **Project directory** mounted at `/home/jovyan/project`

## Quick Setup

### 1. Generate SSH Keys (One-time)

```bash
# Run the setup script on hub host
./scripts/setup-admin-ssh.sh
```

This generates:
- SSH key pair in `.ssh/jupyterlab-admin`
- Authorized keys file for containers

### 2. Build Admin Image

```bash
# Build the admin image with SSH capabilities
docker compose build custom-jupyterlab-admin
```

### 3. Login as Admin

1. **Go to JupyterHub** in browser
2. **Login as admin user**
3. **Start server** → Gets admin container automatically
4. **Open terminal** → See SSH connection info

## Usage

### 1. Get SSH Connection Info

When you open a **terminal in your admin notebook**:
- SSH connection details appear automatically
- Copy the SSH config shown
- Copy the private key from hub host: `cat .ssh/jupyterlab-admin`

### 2. Setup on Local Machine

```bash
# Copy private key to local machine
cat > ~/.ssh/jupyterlab-admin << 'EOF'
[PASTE PRIVATE KEY CONTENT]
EOF

chmod 600 ~/.ssh/jupyterlab-admin

# Add SSH config to ~/.ssh/config
[PASTE SSH CONFIG FROM TERMINAL]
```

### 3. Connect from Local Machine

```bash
ssh jupyterlab-admin
```

### 4. Cursor IDE

1. **Remote-SSH: Connect to Host**
2. **Select**: `jupyterlab-admin`
3. **Working directory**: `/home/jovyan/work`

## Features

- ✅ **Auto-spawn** admin image for admin users
- ✅ **SSH server** with key-based authentication
- ✅ **Sudo access** for system administration  
- ✅ **Project directory** mounted at `/home/jovyan/project`
- ✅ **Enhanced dev tools** (pytest, pylint, uv, etc.)
- ✅ **Auto-display** SSH connection info in terminal

## Directory Structure

```
/home/jovyan/
├── work/           # Notebook workspace (persistent)
│   └── shared_data/    # Shared data from host (read-only)
└── .ssh/           # SSH configuration (auto-mounted)
```

## Terminal Commands

In the admin container terminal:
- `ssh-info` - Show SSH connection details again  
- `notebooks` - Go to notebook workspace (/home/jovyan/work)
- `shared` - Go to shared data directory
- Standard commands: `sudo`, `uv`, `pytest`, etc.

## Notes

- Admin containers are **spawned by JupyterHub** automatically
- **No standalone containers** - clean integration
- **Bash profile** shows SSH info when terminal opens
- SSH daemon starts automatically with the container
