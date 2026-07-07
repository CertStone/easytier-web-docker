#!/bin/bash
set -e
log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"; }

WEB_PORT=${WEB_PORT:-11211}
WEB_API_PORT=${WEB_API_PORT:-11211}
WEB_SERVER_PORT=${WEB_SERVER_PORT:-22020}
WEB_SERVER_PROTOCOL=${WEB_SERVER_PROTOCOL:-udp}
WEB_DEFAULT_API_HOST=${WEB_DEFAULT_API_HOST:-http://127.0.0.1:$WEB_API_PORT}
WEB_LOG_LEVEL=${WEB_LOG_LEVEL:-warn}
WEB_DATA_DIR=/app/data

mkdir -p "$WEB_DATA_DIR/logs"

log "[Web] Starting easytier-web-embed..."
if ! command -v easytier-web-embed &> /dev/null; then
  log "[Web] Error: easytier-web-embed not found."
  exit 1
fi

API_URL="$WEB_DEFAULT_API_HOST"
exec easytier-web-embed \
  -d "$WEB_DATA_DIR/et.db" \
  --console-log-level "$WEB_LOG_LEVEL" \
  --file-log-level "$WEB_LOG_LEVEL" \
  --file-log-dir "$WEB_DATA_DIR/logs" \
  -c "$WEB_SERVER_PORT" \
  -p "$WEB_SERVER_PROTOCOL" \
  -a "$WEB_API_PORT" \
  -l "$WEB_PORT" \
  --api-host "$API_URL"
