#!/bin/bash
set -e

log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"; }

WEB_ENABLE=${WEB_ENABLE:-false}
WEB_PORT=${WEB_PORT:-11211}
WEB_API_PORT=${WEB_API_PORT:-11211}
WEB_SERVER_PORT=${WEB_SERVER_PORT:-22020}
WEB_SERVER_PROTOCOL=${WEB_SERVER_PROTOCOL:-udp}
WEB_DEFAULT_API_HOST=${WEB_DEFAULT_API_HOST:-http://127.0.0.1:$WEB_API_PORT}
WEB_LOG_LEVEL=${WEB_LOG_LEVEL:-warn}
WEB_DATA_DIR=/app/data
CONFIG_DIR=/app/data/config

if [ "$WEB_ENABLE" = "true" ]; then
  mkdir -p "$WEB_DATA_DIR/logs" "$CONFIG_DIR"
  log "[Web] Starting easytier-web-embed..."

  if command -v easytier-web-embed &> /dev/null; then
    BINARY=easytier-web-embed
  else
    log "[Web] Error: easytier-web-embed not found."
    exit 1
  fi

  API_URL="$WEB_DEFAULT_API_HOST"
  log "[Web] Using API URL: $API_URL"

  $BINARY -d "$WEB_DATA_DIR/et.db" \
    --file-log-level "$WEB_LOG_LEVEL" \
    --file-log-dir "$WEB_DATA_DIR/logs" \
    -c "$WEB_SERVER_PORT" \
    -p "$WEB_SERVER_PROTOCOL" \
    -a "$WEB_API_PORT" \
    -l "$WEB_PORT" \
    --api-host "$API_URL" &
fi

log "[Core] Starting easytier-core..."
exec easytier-core "$@"
