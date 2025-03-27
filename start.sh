#!/bin/bash

# Start X virtual framebuffer
Xvfb :1 -screen 0 1920x1080x24 &

# Start Fluxbox window manager
fluxbox &

# Start VNC server
x11vnc -forever -display :1 -passwd password &

# Start noVNC
websockify --web /usr/share/novnc/ --wrap-mode=ignore 3200 localhost:5900 &
  
# Start LightZone
/opt/LightZone/LightZone
