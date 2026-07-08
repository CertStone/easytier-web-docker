#!/bin/bash
set -e
log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"; }

WEB_DATA_DIR=/app/data
mkdir -p "$WEB_DATA_DIR/logs"

# 容器友好默认值（仅当用户未设置时生效）
: "${ET_WEB_DB:=$WEB_DATA_DIR/et.db}"
: "${ET_WEB_FILE_LOG_DIR:=$WEB_DATA_DIR/logs}"
: "${ET_WEB_CONSOLE_LOG_LEVEL:=warn}"
: "${ET_WEB_FILE_LOG_LEVEL:=warn}"

# 注意：上游发布的 easytier-web-embed 二进制未启用 clap 的 env feature
# （--help 中除 OIDC_CLIENT_SECRET 外均无 [env: ...] 标注，ET_* 不会被读取）。
# 因此这里把 ET_* 环境变量翻译为对应的 CLI 参数。
# 仅翻译当前二进制（v2.4.5）--help 中实际存在的 flag。
ARGS=(
  -d "$ET_WEB_DB"
  --console-log-level "$ET_WEB_CONSOLE_LOG_LEVEL"
  --file-log-level "$ET_WEB_FILE_LOG_LEVEL"
  --file-log-dir "$ET_WEB_FILE_LOG_DIR"
)

# 基础参数（Option 类型：仅在已设置时传递）
[ -n "$ET_CONFIG_SERVER_PORT" ]     && ARGS+=(-c "$ET_CONFIG_SERVER_PORT")
[ -n "$ET_CONFIG_SERVER_PROTOCOL" ] && ARGS+=(-p "$ET_CONFIG_SERVER_PROTOCOL")
[ -n "$ET_API_SERVER_PORT" ]        && ARGS+=(-a "$ET_API_SERVER_PORT")
[ -n "$ET_API_SERVER_ADDR" ]        && ARGS+=(--api-server-addr "$ET_API_SERVER_ADDR")
[ -n "$ET_GEOIP_DB" ]               && ARGS+=(--geoip-db "$ET_GEOIP_DB")

# Web Dashboard（仅 embed）
[ -n "$ET_WEB_SERVER_PORT" ] && ARGS+=(-l "$ET_WEB_SERVER_PORT")
[ -n "$ET_WEB_SERVER_ADDR" ] && ARGS+=(--web-server-addr "$ET_WEB_SERVER_ADDR")
[ -n "$ET_API_HOST" ]        && ARGS+=(--api-host "$ET_API_HOST")

# 布尔标志
is_true() { [ "$1" = "true" ] || [ "$1" = "1" ] || [ "$1" = "yes" ]; }
is_true "$ET_NO_WEB"               && ARGS+=(--no-web)
is_true "$ET_DISABLE_REGISTRATION" && ARGS+=(--disable-registration)
is_true "$ET_ALLOW_AUTO_CREATE_USER" && ARGS+=(--allow-auto-create-user)

# Webhook / 内部鉴权
[ -n "$ET_WEBHOOK_URL" ]             && ARGS+=(--webhook-url "$ET_WEBHOOK_URL")
[ -n "$ET_WEBHOOK_SECRET" ]          && ARGS+=(--webhook-secret "$ET_WEBHOOK_SECRET")
[ -n "$ET_INTERNAL_AUTH_TOKEN" ]     && ARGS+=(--internal-auth-token "$ET_INTERNAL_AUTH_TOKEN")
[ -n "$ET_WEB_INSTANCE_ID" ]         && ARGS+=(--web-instance-id "$ET_WEB_INSTANCE_ID")
[ -n "$ET_WEB_INSTANCE_API_BASE_URL" ] && ARGS+=(--web-instance-api-base-url "$ET_WEB_INSTANCE_API_BASE_URL")

# OIDC：client secret 由程序原生读取 env（--help 中唯一带 [env:] 的参数），直接透传即可；
# 其余 OIDC 参数（issuer-url / client-id / scopes / redirect-url 等）仅支持命令行，
# 本镜像不通过 env 暴露，需要时请自定义 ENTRYPOINT。
export OIDC_CLIENT_SECRET

log "[Web] Starting easytier-web-embed..."
log "[Web] Args: ${ARGS[*]}"
exec easytier-web-embed "${ARGS[@]}"
