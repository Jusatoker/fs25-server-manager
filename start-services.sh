#!/bin/bash

# Create noVNC token configuration
cat > /opt/novnc/vnc_tokens.conf << EOF
vnc_auto: localhost:5900
EOF

# Set proper permissions
chown -R wineuser:wineuser /home/wineuser
chown -R wineuser:wineuser /opt/fs25-server

# Initialize Wine if not already done
if [ ! -f /home/wineuser/.wine/system.reg ]; then
    echo "Initializing Wine..."
    su wineuser -c "DISPLAY=:1 WINEPREFIX=/home/wineuser/.wine winecfg"
fi

# Start supervisor to manage all services
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
