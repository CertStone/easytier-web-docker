# easytier-web-docker

原作： MajoSissi

仓库地址：
https://github.com/MajoSissi/easytier-docker 

由于原作者删掉了单Web控制台版镜像，所以有了本仓库~

> 镜像内含 `easytier-web-embed`（前端 + 后端一体）.

## 单 Web 控制台部署

```yaml
services:
  easytier-web:
    image: ghcr.nju.edu.cn/certstone/easytier-web-docker:latest
    container_name: easytier-web
    restart: always
    network: bridge
    ports:
      # Web Dashboard / API（默认同端口）
      - "11211:11211"
      # 配置服务（RPC），easytier-core 通过此端口连入
      - "22020:22020"
    # 限制容器输出日志的大小和数量, 建议启用
    logging:
      driver: "json-file"
      options:
        # 单个日志文件的最大大小  
        max-size: "10m"
        # 最多保留的日志文件数量
        max-file: "5"
    environment:
      TZ: Asia/Shanghai

      # ─────────── 监听 ───────────
      # API / Web 监听端口（默认 11211）
      ET_API_SERVER_PORT: "11211"
      # API / Web 监听地址（默认 0.0.0.0）
      ET_API_SERVER_ADDR: "0.0.0.0"
      # Web Dashboard 端口；不设则与 API 同端口（默认 11211）
      # ET_WEB_SERVER_PORT: "11211"
      # Web Dashboard 监听地址（默认 0.0.0.0）
      # ET_WEB_SERVER_ADDR: "0.0.0.0"
      # 前端连接后端 API 的 URL（分离部署时必填）
      # ET_API_HOST: "http://你的主机:11211"

      # ─────────── 配置服务（RPC） ───────────
      # 配置服务监听端口，供 easytier-core 连接（默认 22020）
      ET_CONFIG_SERVER_PORT: "22020"
      # 配置服务协议：udp / tcp / ws（默认 udp）
      ET_CONFIG_SERVER_PROTOCOL: "udp"

      # ─────────── 日志 / 数据 ───────────
      # 控制台日志级别：off/error/warn/info/debug/trace（默认 warn）
      ET_WEB_CONSOLE_LOG_LEVEL: "warn"
      # 文件日志级别（默认 warn）
      ET_WEB_FILE_LOG_LEVEL: "warn"
      # sqlite3 数据库路径（默认 /app/data/et.db）
      ET_WEB_DB: "/app/data/et.db"
      # 日志文件目录（默认 /app/data/logs）
      ET_WEB_FILE_LOG_DIR: "/app/data/logs"

      # ─────────── 高级 ───────────
      # GeoIP2 数据库路径（内置仅含国家，可选填自定义库）
      # ET_GEOIP_DB: "/app/data/geoip.mmdb"
      # 心跳 RPC 最短响应时间（毫秒，默认 0）
      # ET_HEARTBEAT_MIN_RESPONSE_MS: "0"
      # 不运行 Web Dashboard（默认 false）
      # ET_NO_WEB: "false"

      # ─────────── Feature Flags ───────────
      # 禁用 Web UI 用户注册（默认 false）
      # ET_DISABLE_REGISTRATION: "false"
      # easytier-core 用未知用户名连入时自动建本地用户（默认 false）
      # ET_ALLOW_AUTO_CREATE_USER: "false"

      # ─────────── Webhook / 内部鉴权 ───────────
      # 出站 webhook 的共享密钥（敏感，已隐藏）
      # ET_WEBHOOK_SECRET: "your-webhook-secret"
      # webhook 端点基址
      # ET_WEBHOOK_URL: "https://your-host/webhook"
      # 携带 X-Internal-Auth 头可绕过会话鉴权的 token（敏感，已隐藏）
      # ET_INTERNAL_AUTH_TOKEN: "your-internal-token"
      # 本实例在 webhook 回调中的稳定标识
      # ET_WEB_INSTANCE_ID: "inst-1"
      # 本实例内部 REST API 的可达基址
      # ET_WEB_INSTANCE_API_BASE_URL: "http://your-host:11211"

      # ─────────── OIDC 单点登录 ───────────
      # 注意：除 client secret 外，OIDC 其余参数仅支持命令行，无 env。
      # OIDC_CLIENT_SECRET: "your-oidc-client-secret"
      # 其余（--oidc-issuer-url / --oidc-client-id / --oidc-redirect-url 等）
      # 因 easytier-web-embed 不读取 env，需要时请用命令行参数启动。
    volumes:
      - ./data:/app/data
```

### 环境变量参考

镜像内 `easytier-web-embed` 通过 clap `env="..."` 直接读取下列变量（无需在启动脚本里再翻译）。

#### 基础（embed / 非 embed 共有）

| 环境变量 | 类型 | 默认 | 说明 |
|---|---|---|---|
| `ET_WEB_DB` | String | `et.db` | sqlite3 数据库路径 |
| `ET_WEB_CONSOLE_LOG_LEVEL` | off/error/warn/info/debug/trace | — | 控制台日志级别 |
| `ET_WEB_FILE_LOG_LEVEL` | off/error/warn/info/debug/trace | — | 文件日志级别 |
| `ET_WEB_FILE_LOG_DIR` | String | 当前目录 | 日志文件目录 |
| `ET_CONFIG_SERVER_PORT` | u16 | `22020` | 配置服务（RPC）端口 |
| `ET_CONFIG_SERVER_PROTOCOL` | udp/tcp/ws | `udp` | 配置服务协议 |
| `ET_API_SERVER_PORT` | u16 | `11211` | API 端口 |
| `ET_API_SERVER_ADDR` | IpAddr | `0.0.0.0` | API 监听地址 |
| `ET_GEOIP_DB` | String | 内置 | GeoIP2 数据库路径 |
| `ET_HEARTBEAT_MIN_RESPONSE_MS` | u64 | `0` | 心跳最短响应时间（ms） |

#### Web Dashboard（**仅 embed**）

| 环境变量 | 类型 | 默认 | 说明 |
|---|---|---|---|
| `ET_WEB_SERVER_PORT` | u16 | 与 API 同端口 | Web Dashboard 端口 |
| `ET_WEB_SERVER_ADDR` | IpAddr | `0.0.0.0` | Web Dashboard 监听地址 |
| `ET_NO_WEB` | bool | `false` | 不运行 Web Dashboard |
| `ET_API_HOST` | URL | — | 前端连接 API 的 URL |

#### Feature Flags

| 环境变量 | 类型 | 默认 | 说明 |
|---|---|---|---|
| `ET_DISABLE_REGISTRATION` | bool | `false` | 禁用 Web UI 注册 |
| `ET_ALLOW_AUTO_CREATE_USER` | bool | `false` | 未知用户名自动建本地用户 |

#### Webhook / 内部鉴权

| 环境变量 | 备注 | 说明 |
|---|---|---|
| `ET_WEBHOOK_URL` | String | webhook 端点基址 |
| `ET_WEBHOOK_SECRET` | **隐藏** | webhook 共享密钥 |
| `ET_INTERNAL_AUTH_TOKEN` | **隐藏** | 绕过会话鉴权的 token |
| `ET_WEB_INSTANCE_ID` | String | webhook 回调中的实例标识 |
| `ET_WEB_INSTANCE_API_BASE_URL` | String | 本实例内部 REST API 基址 |

#### OIDC（部分）

| 环境变量 | 备注 | 说明 |
|---|---|---|
| `OIDC_CLIENT_SECRET` | 无 `ET_` 前缀 | OIDC client secret |
| `--oidc-*` 其余 | 仅命令行 | issuer / client-id / scopes / redirect-url 等不支持 env |

> **为什么没有旧的 `WEB_PORT` / `WEB_API_PORT` / `WEB_LOG_LEVEL` 变量了？**
> 旧版镜像用了一套自造的环境变量名做翻译层，与官方 `ET_*` 不兼容，且只暴露了 6 个参数。新版直接透传 clap 原生 `env="..."`，所有 20 个变量全部可用，与官方文档一致。

## ~~完整版 ( Core组网 + Web控制台 )~~ 

本仓库不维护完整版镜像
