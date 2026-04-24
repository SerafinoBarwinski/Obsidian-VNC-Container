#!/bin/bash

set -euo pipefail

APP_DIR=/app
APPIMAGE_PATH="$APP_DIR/Obsidian.AppImage"
FALLBACK_URL="https://github.com/obsidianmd/obsidian-releases/releases/download/v1.12.7/Obsidian-1.12.7.AppImage"
VNC_PASSWORD="${VNC_PASSWORD:-obsidian}"

OBS_PID=""
WS_PID=""
VNC_PID=""

mkdir -p "$APP_DIR"
cd "$APP_DIR"

cleanup() {
    echo "[INFO] Shutting down..."

    [ -n "$OBS_PID" ] && kill "$OBS_PID" 2>/dev/null || true
    [ -n "$WS_PID" ] && kill "$WS_PID" 2>/dev/null || true

    vncserver -kill :1 || true

    echo "[INFO] Shutdown complete"
    exit 0
}

trap cleanup SIGINT SIGTERM

download_latest() {
    curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest \
    | jq -r '.assets[] | select(.name | test("AppImage") and test("x86_64") and (test("arm") | not)) | .browser_download_url' \
    | head -n 1
}

if [ ! -f "$APPIMAGE_PATH" ]; then
    echo "[INFO] Downloading Obsidian..."

    URL=$(download_latest || true)

    if [ -n "${URL:-}" ]; then
        wget -q -O "$APPIMAGE_PATH" "$URL" || wget -q -O "$APPIMAGE_PATH" "$FALLBACK_URL"
    else
        wget -q -O "$APPIMAGE_PATH" "$FALLBACK_URL"
    fi

    chmod +x "$APPIMAGE_PATH"
    echo "[INFO] Done Downloading"
fi

if [ ! -f /root/.vnc/passwd ]; then
    mkdir -p /root/.vnc
    echo "${VNC_PASSWORD}" | vncpasswd -f > /root/.vnc/passwd
    chmod 600 /root/.vnc/passwd
    cat /root/.vnc/passwd
fi

vncserver -kill :1 || true
vncserver :1 -geometry 1280x800 -localhost no -depth 24

export DISPLAY=:1

sleep 2

echo "[INFO] Preparing Obsidian"
"$APPIMAGE_PATH" --appimage-extract
mv squashfs-root obsidian


echo "[INFO] Creating Desktop Launcher"
cat > /root/Desktop/obsidian.desktop <<EOF
[Desktop Entry]
Name=Obsidian
Exec=/app/obsidian/obsidian --no-sandbox
Icon=/app/obsidian/resources/app/icon.png
Type=Application
Categories=Utility;
EOF
chmod +x /root/Desktop/obsidian.desktop


echo "[INFO] Starting Obsidian"
/app/obsidian/obsidian --no-sandbox &

echo "[INFO] Starting noVNC"
websockify --web=/usr/share/novnc/ 6080 localhost:5901

wait