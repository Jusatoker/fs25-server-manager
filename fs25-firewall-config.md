# FS25 Server Firewall Configuration Guide

Based on your existing firewall policy structure, here's how to configure firewall rules for your FS25 Server Manager.

## Required FS25 Server Ports

### Web Management Interface
- **Port 80 (HTTP)** - Web dashboard access
- **Port 443 (HTTPS)** - Secure web access (if SSL configured)

### Remote Access
- **Port 5900 (VNC)** - Direct VNC access
- **Port 6080 (noVNC)** - Browser-based VNC

### Game Server
- **Port 10823 (TCP/UDP)** - FS25 dedicated server port

## Recommended Firewall Rules

### 8. Allow FS25 Web Interface (External → DMZ)
- **Name:** Allow FS25 Web Interface
- **Action:** Allow
- **Protocol:** TCP
- **Ports:** 80, 443
- **Source Zone:** External
- **Source:** Any (or restrict to specific IPs)
- **Destination Zone:** DMZ
- **Destination:** 96.61.113.210 (Your Game Server VM)
- **Connection State:** All

### 9. Allow FS25 VNC Access (Internal → DMZ)
- **Name:** Allow FS25 VNC Access
- **Action:** Allow
- **Protocol:** TCP
- **Ports:** 5900, 6080
- **Source Zone:** Internal
- **Source:** Any (or restrict to admin IPs)
- **Destination Zone:** DMZ
- **Destination:** 96.61.113.210
- **Connection State:** All

### 10. Allow FS25 Game Server (External → DMZ)
- **Name:** Allow FS25 Game Server
- **Action:** Allow
- **Protocol:** TCP/UDP
- **Ports:** 10823
- **Source Zone:** External
- **Source:** Any
- **Destination Zone:** DMZ
- **Destination:** 96.61.113.210
- **Connection State:** All

## Updated Game Ports Rule (Modify Rule #7)

Update your existing "Allow Game Ports" rule to include FS25:

### 7. Allow Game Ports Inbound (External → DMZ) - UPDATED
- **Name:** Allow Game Ports
- **Action:** Allow
- **Protocol:** UDP/TCP
- **Ports:** 
  - 27015 (Steam/Source games)
  - 7777 (Ark/Terraria)
  - 25565 (Minecraft)
  - 2456-2458 (Valheim)
  - 28015 (Rust)
  - **10823 (Farming Simulator 25)** ← ADD THIS
  - **80, 443 (FS25 Web Interface)** ← ADD THIS
- **Source Zone:** External
- **Source:** Any
- **Destination Zone:** DMZ
- **Destination:** 96.61.113.210 (Game Server VM)
- **Connection State:** All

## Security Recommendations

### Option 1: Restrict Web Interface Access
For better security, consider restricting web interface access to internal networks only:

```
Source Zone: Internal (instead of External)
Source: Your admin network range (e.g., 192.168.1.0/24)
```

### Option 2: VPN Access Only
Set up VPN access for administrative tasks:
- Keep game server port (10823) open to External
- Restrict web interface and VNC to VPN clients only

## Implementation Steps

1. **Log into your UniFi Controller**
2. **Navigate to:** Settings → Security → Traffic & Firewall Rules
3. **Add the new rules** in the order specified above
4. **Test connectivity** after each rule addition
5. **Monitor logs** for any blocked legitimate traffic

## Port Testing Commands

After implementing the rules, test connectivity:

```bash
# Test web interface
curl -I http://96.61.113.210

# Test game server port
telnet 96.61.113.210 10823

# Test VNC (from internal network)
telnet 96.61.113.210 5900
```

## Troubleshooting

If connections fail:
1. Check rule order (more specific rules should come first)
2. Verify zone assignments for your network interfaces
3. Check UniFi logs for blocked connections
4. Ensure the FS25 server container is running and listening on the correct ports

## Docker Container Network Configuration

Make sure your docker-compose.yml has the correct port mappings:

```yaml
ports:
  - "80:80"           # Web interface
  - "5900:5900"       # VNC
  - "6080:6080"       # noVNC
  - "10823:10823"     # FS25 server port
```

This configuration follows your existing security model while providing the necessary access for your FS25 server.
