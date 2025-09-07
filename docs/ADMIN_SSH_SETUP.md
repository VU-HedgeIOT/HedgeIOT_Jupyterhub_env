# Admin SSH Access Setup

This guide explains how to set up SSH access to a dedicated admin JupyterLab container for remote development with tools like Cursor, VS Code, or direct SSH access.

## Features

The admin container includes:
- **SSH Server** with key-based authentication
- **Sudo access** for system administration
- **Enhanced development tools** (pytest, pylint, mypy, etc.)
- **Full JupyterLab environment** with uv package management
- **Persistent workspace** separate from regular users
- **Project directory mounting** for direct development access

## Quick Setup

### 1. Generate SSH Keys and Setup

```bash
# Run the setup script
./scripts/setup-admin-ssh.sh
```

This script will:
- Generate SSH key pair (`.ssh/jupyterlab-admin`)
- Create authorized_keys file
- Set up SSH config for easy connection

### 2. Build and Start Admin Container

```bash
# Build the admin image
docker compose build jupyterlab-admin

# Start the admin container
docker compose --profile admin up -d jupyterlab-admin
```

### 3. Connect via SSH

```bash
# Connect using SSH config
ssh -F .ssh/config jupyterlab-admin

# Or connect directly
ssh -i .ssh/jupyterlab-admin -p 2222 jovyan@localhost
```

## Remote Development Setup

### Direct SSH Connection from Local Machine

Add this to your **local machine's** `~/.ssh/config`:

```ssh-config
# Direct connection to admin container (single command)
Host jupyterlab-admin
    HostName localhost
    Port 2222
    User jovyan
    IdentityFile ~/.ssh/jupyterlab-admin
    ProxyCommand ssh -W localhost:2222 hedgeiot
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
```

**Copy SSH keys to local machine:**
```bash
# Private key (copy from remote host output above)
cat > ~/.ssh/jupyterlab-admin << 'EOF'
[PASTE PRIVATE KEY FROM REMOTE HOST]
EOF

# Set permissions
chmod 600 ~/.ssh/jupyterlab-admin
```

**Connect with single command:**
```bash
ssh jupyterlab-admin  # Direct connection - no multiple terminals!
```

### Cursor IDE Setup

1. **Remote-SSH: Connect to Host**
2. **Select**: `jupyterlab-admin` 
3. **Working directory**: `/home/jovyan/project`

## Access Points

| Service | URL/Command | Description |
|---------|-------------|-------------|
| **SSH Access** | `ssh -F .ssh/config jupyterlab-admin` | Direct terminal access |
| **JupyterLab** | `http://localhost:8889` | Web-based notebook interface |
| **Token** | `admin-dev-token` | JupyterLab access token |

## Directory Structure

Inside the container:

```
/home/jovyan/
├── work/           # Persistent admin workspace (volume)
├── shared_data/    # Shared data from host project
├── project/        # Direct mount of entire project
└── .ssh/           # SSH configuration
```

## Security Features

- ✅ **Key-based authentication only** (passwords disabled)
- ✅ **Root login disabled**
- ✅ **Sudo access** for jovyan user (passwordless)
- ✅ **Isolated network** (same as JupyterHub)
- ✅ **Non-root runtime** (runs as jovyan user)

## Development Workflow

### 1. System Administration
```bash
# SSH into container
ssh -F .ssh/config jupyterlab-admin

# Install system packages
sudo apt update && sudo apt install package-name

# Install Python packages
uv pip install package-name
```

### 2. Code Development
- Use Cursor/VS Code to connect remotely
- Edit files in `/home/jovyan/project/` (direct project access)
- Changes are immediately reflected on host

### 3. JupyterLab Access
- Open browser: `http://localhost:8889`
- Enter token: `admin-dev-token`
- Access notebooks and project files

## Troubleshooting

### SSH Connection Issues

```bash
# Check if container is running
docker compose ps jupyterlab-admin

# Check SSH service in container
docker compose exec jupyterlab-admin systemctl status ssh

# Check SSH logs
docker compose logs jupyterlab-admin
```

### Permission Issues

```bash
# Fix SSH key permissions
chmod 600 .ssh/jupyterlab-admin
chmod 644 .ssh/jupyterlab-admin.pub
chmod 600 .ssh/authorized_keys
```

### Port Conflicts

If port 2222 is in use:
1. Change port in `docker-compose.yml`: `"2223:22"`
2. Update SSH config: `Port 2223`
3. Restart container: `docker compose --profile admin restart jupyterlab-admin`

## Commands Reference

```bash
# Setup SSH keys
./scripts/setup-admin-ssh.sh

# Build admin image
docker compose build jupyterlab-admin

# Start admin container only
docker compose --profile admin up -d jupyterlab-admin

# Stop admin container
docker compose --profile admin down jupyterlab-admin

# View logs
docker compose logs -f jupyterlab-admin

# Connect via SSH
ssh -F .ssh/config jupyterlab-admin

# Execute commands in container
docker compose exec jupyterlab-admin bash
```

## Notes

- The admin container runs **independently** of the main JupyterHub service
- Uses **profile "admin"** to avoid starting with regular services
- Includes **enhanced development packages** not in regular user containers
- Has **persistent storage** separate from user containers
- Provides **full project access** for development work
