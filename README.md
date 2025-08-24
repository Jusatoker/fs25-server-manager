# Farming Simulator 25 Server Manager

A complete Docker-based solution for running a Farming Simulator 25 dedicated server with Wine, featuring a web-based management interface and remote GUI access.

## Features

- 🚜 **FS25 Dedicated Server** running in Wine within Docker
- 🌐 **Web Management Interface** for server control and monitoring
- 🖥️ **Remote GUI Access** via noVNC for server configuration
- 📊 **Real-time System Monitoring** (CPU, Memory, Disk usage)
- 🔄 **Server Update Management** with customizable update scripts
- 📝 **Log Viewing** and server status monitoring
- 🐳 **Easy Docker Deployment** with docker-compose

## Quick Start

### Prerequisites

- Docker and Docker Compose installed
- At least 4GB RAM available
- Farming Simulator 25 dedicated server files

### 1. Clone and Setup

```bash
git clone <your-repo-url>
cd fs25-server-manager
```

### 2. Add FS25 Server Files

Place your Farming Simulator 25 dedicated server files in the `server-data/` directory:

```
server-data/
├── dedicatedServer.exe
├── (other FS25 server files)
└── update_server.sh
```

### 3. Build and Run

```bash
# Build and start the container
docker-compose up -d

# View logs
docker-compose logs -f
```

### 4. Access the Interface

- **Web Management**: http://localhost
- **Server GUI (noVNC)**: http://localhost/vnc/
- **Direct VNC**: localhost:5900

## Usage

### Web Interface

The web interface provides:

- **Server Control**: Start, stop, restart the FS25 server
- **System Monitoring**: Real-time CPU, memory, and disk usage
- **Update Management**: Run server updates via the web interface
- **Log Viewing**: View server logs and troubleshoot issues
- **GUI Access**: Direct link to the server's graphical interface

### Server Management

#### Starting the Server
1. Access the web interface at http://localhost
2. Click "Start Server" in the Server Control panel
3. Monitor the status indicator for confirmation

#### Accessing Server GUI
1. Click "Server GUI" button in the web interface
2. This opens noVNC in a new tab
3. You can now interact with the FS25 server GUI directly

#### Updating the Server
1. Customize the `server-data/update_server.sh` script for your update method
2. Click "Update Server" in the web interface
3. Monitor the logs for update progress

### Configuration

#### Wine Configuration
The container automatically sets up Wine with a 64-bit prefix. If you need to modify Wine settings:

1. Access the server GUI via noVNC
2. Run `winecfg` in the terminal
3. Adjust settings as needed

#### Server Configuration
- Place your `dedicatedServer.xml` and other config files in `server-data/`
- Modify server settings through the GUI or by editing config files directly

## Directory Structure

```
fs25-server-manager/
├── Dockerfile                      # Main container definition
├── docker-compose.yml             # Docker Compose configuration
├── supervisord.conf               # Service management configuration
├── nginx.conf                     # Web server configuration
├── start-services.sh              # Container startup script
├── requirements.txt               # Python dependencies
├── web-interface/                 # Web management interface
│   ├── app.py                     # Flask application
│   └── templates/
│       └── index.html             # Web interface template
├── server-data/                   # FS25 server files (mounted volume)
│   ├── dedicatedServer.exe        # FS25 server executable
│   ├── update_server.sh           # Server update script
│   └── (other server files)
└── logs/                          # Container logs (mounted volume)
```

## Ports

- **80**: Web management interface
- **5900**: VNC server (direct access)
- **6080**: noVNC web interface
- **10823**: FS25 server game port

## Volumes

- `./server-data`: FS25 server files and configurations
- `./logs`: Supervisor and application logs
- `fs25-wine-data`: Wine prefix data (persistent)

## Customization

### Update Script

Modify `server-data/update_server.sh` to implement your preferred update method:

```bash
# Option 1: SteamCMD (if available)
/opt/steamcmd/steamcmd.sh +login anonymous +force_install_dir /opt/fs25-server +app_update 2089300 validate +quit

# Option 2: Direct download
wget -O fs25-server-update.zip "YOUR_UPDATE_URL"
unzip -o fs25-server-update.zip

# Option 3: Custom logic
# Add your specific update process here
```

### Web Interface

The Flask application can be extended with additional features:
- Custom server configurations
- Player management
- Mod management
- Backup/restore functionality

## Troubleshooting

### Server Won't Start
1. Check that `dedicatedServer.exe` exists in `server-data/`
2. Verify Wine is properly initialized
3. Check logs: `docker-compose logs fs25-server`

### GUI Access Issues
1. Ensure noVNC is running: check port 6080
2. Try direct VNC connection on port 5900
3. Restart the container: `docker-compose restart`

### Performance Issues
1. Increase container memory limits in docker-compose.yml
2. Monitor system resources in the web interface
3. Check host system resources

### Update Script Fails
1. Verify the update script has proper permissions
2. Check the script logic matches your update source
3. Review update logs in the web interface

## Development

### Building from Source

```bash
# Build the image
docker build -t fs25-server-manager .

# Run with custom configuration
docker run -d \
  -p 80:80 \
  -p 5900:5900 \
  -p 6080:6080 \
  -p 10823:10823 \
  -v $(pwd)/server-data:/opt/fs25-server \
  fs25-server-manager
```

### Modifying the Web Interface

1. Edit files in `web-interface/`
2. Rebuild the container: `docker-compose build`
3. Restart: `docker-compose up -d`

## Security Considerations

- The container runs with minimal privileges
- Consider using a reverse proxy with SSL for production
- Restrict access to management ports (5900, 6080)
- Regularly update the base Ubuntu image

## Support

For issues and questions:
1. Check the logs: `docker-compose logs`
2. Verify your FS25 server files are correct
3. Ensure Docker has sufficient resources allocated

## License

This project is provided as-is for educational and personal use. Farming Simulator 25 is a trademark of Giants Software.
