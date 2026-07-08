#!/bin/bash
set -e
log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"; }

WEB_DATA_DIR=/app/data
mkdir -p "$WEB_DATA_DIR/logs"

# 容器友好默认值（仅当用户未通过原生 ET_* 变量覆盖时生效）
# 其余所有参数均由 easytier-web-embed 通过 clap 的 env="..." 原生读取，无需在此翻译
: "${ET_WEB_DB:=$WEB_DATA_DIR/et.db}"
: "${ET_WEB_FILE_LOG_DIR:=$WEB_DATA_DIR/logs}"
: "${ET_WEB_CONSOLE_LOG_LEVEL:=warn}"
: "${ET_WEB_FILE_LOG_LEVEL:=warn}"
export ET_WEB_DB ET_WEB_FILE_LOG_DIR ET_WEB_CONSOLE_LOG_LEVEL ET_WEB_FILE_LOG_LEVEL

log "[Web] Starting easytier-web-embed..."
if ! command -v easytier-web-embed &> /dev/null; then
  log "[Web] Error: easytier-web-embed not found."
  exit 1
fi

# 不传任何业务参数，全部交给 clap 的 env 支持 + 上述默认值
exec easytier-web-embed
