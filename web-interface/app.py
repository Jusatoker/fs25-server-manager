#!/usr/bin/env python3

import os
import subprocess
import json
import psutil
from flask import Flask, render_template, request, jsonify, redirect, url_for
from flask_socketio import SocketIO, emit
import threading
import time

app = Flask(__name__)
app.config['SECRET_KEY'] = 'fs25-server-secret-key'
socketio = SocketIO(app, cors_allowed_origins="*")

# Global variables
server_process = None
server_status = "stopped"

def get_system_info():
    """Get system information"""
    try:
        cpu_percent = psutil.cpu_percent(interval=1)
        memory = psutil.virtual_memory()
        disk = psutil.disk_usage('/')
        
        return {
            'cpu_percent': cpu_percent,
            'memory_percent': memory.percent,
            'memory_used': memory.used // (1024**3),  # GB
            'memory_total': memory.total // (1024**3),  # GB
            'disk_percent': disk.percent,
            'disk_used': disk.used // (1024**3),  # GB
            'disk_total': disk.total // (1024**3)  # GB
        }
    except Exception as e:
        return {'error': str(e)}

def check_server_status():
    """Check if FS25 server is running"""
    global server_status
    try:
        # Check if dedicatedServer.exe is running
        for proc in psutil.process_iter(['pid', 'name', 'cmdline']):
            if 'dedicatedServer.exe' in proc.info['name'] or \
               (proc.info['cmdline'] and any('dedicatedServer.exe' in cmd for cmd in proc.info['cmdline'])):
                server_status = "running"
                return True
        server_status = "stopped"
        return False
    except Exception as e:
        server_status = "error"
        return False

def monitor_system():
    """Background thread to monitor system and emit updates"""
    while True:
        try:
            system_info = get_system_info()
            server_running = check_server_status()
            
            socketio.emit('system_update', {
                'system_info': system_info,
                'server_status': server_status,
                'server_running': server_running
            })
            
            time.sleep(5)  # Update every 5 seconds
        except Exception as e:
            print(f"Monitor error: {e}")
            time.sleep(10)

@app.route('/')
def index():
    """Main dashboard"""
    return render_template('index.html')

@app.route('/vnc')
def vnc():
    """VNC access page"""
    return redirect('/vnc/')

@app.route('/api/server/start', methods=['POST'])
def start_server():
    """Start the FS25 server"""
    try:
        # Use supervisorctl to start the server
        result = subprocess.run(['supervisorctl', 'start', 'fs25-server'], 
                              capture_output=True, text=True)
        
        if result.returncode == 0:
            return jsonify({'success': True, 'message': 'Server start command sent'})
        else:
            return jsonify({'success': False, 'message': f'Failed to start server: {result.stderr}'})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)})

@app.route('/api/server/stop', methods=['POST'])
def stop_server():
    """Stop the FS25 server"""
    try:
        # Use supervisorctl to stop the server
        result = subprocess.run(['supervisorctl', 'stop', 'fs25-server'], 
                              capture_output=True, text=True)
        
        if result.returncode == 0:
            return jsonify({'success': True, 'message': 'Server stop command sent'})
        else:
            return jsonify({'success': False, 'message': f'Failed to stop server: {result.stderr}'})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)})

@app.route('/api/server/restart', methods=['POST'])
def restart_server():
    """Restart the FS25 server"""
    try:
        # Use supervisorctl to restart the server
        result = subprocess.run(['supervisorctl', 'restart', 'fs25-server'], 
                              capture_output=True, text=True)
        
        if result.returncode == 0:
            return jsonify({'success': True, 'message': 'Server restart command sent'})
        else:
            return jsonify({'success': False, 'message': f'Failed to restart server: {result.stderr}'})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)})

@app.route('/api/server/update', methods=['POST'])
def update_server():
    """Update the FS25 server"""
    try:
        # This would typically involve SteamCMD or similar
        # For now, we'll create a placeholder that can be customized
        update_script = '/opt/fs25-server/update_server.sh'
        
        if os.path.exists(update_script):
            result = subprocess.run(['bash', update_script], 
                                  capture_output=True, text=True)
            
            if result.returncode == 0:
                return jsonify({'success': True, 'message': 'Server update completed', 'output': result.stdout})
            else:
                return jsonify({'success': False, 'message': f'Update failed: {result.stderr}'})
        else:
            return jsonify({'success': False, 'message': 'Update script not found. Please create /opt/fs25-server/update_server.sh'})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)})

@app.route('/api/system/info')
def system_info():
    """Get current system information"""
    info = get_system_info()
    info['server_status'] = server_status
    info['server_running'] = check_server_status()
    return jsonify(info)

@app.route('/api/logs')
def get_logs():
    """Get server logs"""
    try:
        log_files = [
            '/var/log/supervisor/fs25-server-stdout---supervisor-*.log',
            '/var/log/supervisor/fs25-server-stderr---supervisor-*.log'
        ]
        
        logs = {}
        for log_pattern in log_files:
            try:
                # Get the most recent log file matching the pattern
                result = subprocess.run(['bash', '-c', f'ls -t {log_pattern} 2>/dev/null | head -1'], 
                                      capture_output=True, text=True)
                if result.stdout.strip():
                    log_file = result.stdout.strip()
                    with open(log_file, 'r') as f:
                        logs[os.path.basename(log_file)] = f.read()[-5000:]  # Last 5000 chars
            except Exception as e:
                logs[f'error_{log_pattern}'] = str(e)
        
        return jsonify(logs)
    except Exception as e:
        return jsonify({'error': str(e)})

if __name__ == '__main__':
    # Start system monitoring in background
    monitor_thread = threading.Thread(target=monitor_system, daemon=True)
    monitor_thread.start()
    
    # Run the Flask app
    socketio.run(app, host='0.0.0.0', port=5000, debug=False)
