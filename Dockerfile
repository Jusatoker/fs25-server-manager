FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install Wine and dependencies
RUN apt-get update && apt-get install -y \
    wget \
    gnupg2 \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    curl \
    xvfb \
    x11vnc \
    fluxbox \
    supervisor \
    nginx \
    python3 \
    python3-pip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Add Wine repository and install Wine
RUN dpkg --add-architecture i386 \
    && mkdir -pm755 /etc/apt/keyrings \
    && wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
    && wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources \
    && apt-get update \
    && apt-get install -y --install-recommends winehq-stable \
    && rm -rf /var/lib/apt/lists/*

# Install noVNC for web-based VNC access
RUN wget -qO- https://github.com/novnc/noVNC/archive/v1.4.0.tar.gz | tar xz -C /opt/ \
    && mv /opt/noVNC-1.4.0 /opt/novnc \
    && wget -qO- https://github.com/novnc/websockify/archive/v0.11.0.tar.gz | tar xz -C /opt/ \
    && mv /opt/websockify-0.11.0 /opt/websockify

# Create wine user
RUN useradd -m -s /bin/bash wineuser \
    && usermod -aG sudo wineuser

# Set up Wine prefix
USER wineuser
WORKDIR /home/wineuser
RUN mkdir -p /home/wineuser/.wine \
    && WINEARCH=win64 WINEPREFIX=/home/wineuser/.wine winecfg

# Switch back to root for system configuration
USER root

# Create directories for the server
RUN mkdir -p /opt/fs25-server \
    && mkdir -p /var/log/supervisor \
    && mkdir -p /opt/web-interface

# Copy configuration files
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY web-interface/ /opt/web-interface/
COPY start-services.sh /opt/start-services.sh

# Install Python dependencies for web interface
COPY requirements.txt /opt/web-interface/requirements.txt
RUN pip3 install -r /opt/web-interface/requirements.txt

# Make scripts executable
RUN chmod +x /opt/start-services.sh

# Expose ports
EXPOSE 80 5900 6080 10823

# Set environment variables
ENV DISPLAY=:1
ENV WINEPREFIX=/home/wineuser/.wine

# Start services
CMD ["/opt/start-services.sh"]
