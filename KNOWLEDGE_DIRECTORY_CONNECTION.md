# Knowledge Directory Connection Configuration

## Summary

JupyterHub environment is now connected to the local Knowledge Directory VM instead of the external endpoint.

## Configuration Details

### Network Information
- **JupyterHub VM**: `nlahstg01l151` (VM ID 2151) - IP: `10.111.10.154`
- **Knowledge Directory VM**: `nlahstg01l141` (VM ID 2141) - IP: `10.111.10.192`
- **Network**: Both VMs on same Proxmox bridge (`vmbr0`) with VLAN tag `111`
- **Knowledge Directory Port**: `8210` (exposed from container port 8282)

### Files Modified

#### 1. `.env` (Created)
Environment variables for deployment configuration:
```bash
KD_URL=http://10.111.10.192:8210/kd
KNOWLEDGE_ENGINE_CONTAINER_NAME=knowledge-engine
KNOWLEDGE_ENGINE_PORT=8280
KE_RUNTIME_EXPOSED_URL=http://localhost:8082
KE_USER=your_ke_username
KE_PASS=your_ke_password
GRAPHDB_EXTERNAL_URL=http://localhost:7200
```

#### 2. `docker-compose.yml`
**Line 46** changed from:
```yaml
KD_URL: https://${KE_USER}:${KE_PASS}@hedgeiot.knowledge-engine.eu/kd
```

To:
```yaml
KD_URL: ${KD_URL}
```

## Deployment Configuration

### For Local KD (Current Setup)
In `.env`:
```bash
KD_URL=http://10.111.10.192:8210/kd
```

### For External KD (Original)
In `.env`:
```bash
KD_URL=https://hedgeiot.knowledge-engine.eu/kd
```

### With Authentication
If the Knowledge Directory requires authentication, include credentials in the URL:
```bash
KD_URL=http://${KE_USER}:${KE_PASS}@10.111.10.192:8210/kd
```

## Verification

Connection verified:
- ✅ Network connectivity: JupyterHub VM → KD VM
- ✅ Port 8210 accessible
- ✅ Docker Compose configuration valid
- ✅ Knowledge Engine container restarted successfully

## Maintenance

### To Switch Between KD Endpoints
1. Edit `/home/matt/HedgeIOT_Jupyterhub_env/.env`
2. Update the `KD_URL` variable
3. Restart the service:
   ```bash
   cd /home/matt/HedgeIOT_Jupyterhub_env
   docker compose restart knowledge-engine
   ```

### To Verify Configuration
```bash
cd /home/matt/HedgeIOT_Jupyterhub_env
docker compose config | grep KD_URL
```

### To Check Logs
```bash
docker logs --tail 100 knowledge-engine-jh
```

## Network Topology

```
┌─────────────────────────────────────┐
│  Proxmox Host (hedgepve)            │
│  Bridge: vmbr0, VLAN: 111           │
│                                     │
│  ┌──────────────────────────────┐  │
│  │ VM 2151 (nlahstg01l151)      │  │
│  │ IP: 10.111.10.154            │  │
│  │                               │  │
│  │ ┌─────────────────────────┐  │  │
│  │ │ knowledge-engine:8280   │──┼──┼──► http://10.111.10.192:8210/kd
│  │ │ JupyterHub              │  │  │
│  │ │ GraphDB:7200            │  │  │
│  │ │ nginx:4050              │  │  │
│  │ └─────────────────────────┘  │  │
│  └──────────────────────────────┘  │
│                                     │
│  ┌──────────────────────────────┐  │
│  │ VM 2141 (nlahstg01l141)      │  │
│  │ IP: 10.111.10.192            │  │
│  │                               │  │
│  │ ┌─────────────────────────┐  │  │
│  │ │ Knowledge Directory     │  │  │
│  │ │ Port: 8210 → 8282       │  │  │
│  │ │ Smart Meters            │  │  │
│  │ │ BMS, Solar, etc.        │  │  │
│  │ └─────────────────────────┘  │  │
│  └──────────────────────────────┘  │
└─────────────────────────────────────┘
```

## Notes

- No changes were made to the Knowledge Directory VM Docker environment
- Connection uses HTTP (not HTTPS) for internal VM communication
- Firewall rules not needed - port 8210 was already accessible
- Configuration is now deployment-agnostic via `.env` file

