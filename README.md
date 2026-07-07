# easytier-web

原作： MajoSissi

仓库地址：
https://github.com/MajoSissi/easytier-docker 

由于原作者删掉了单Web控制台版镜像，所以有了本仓库~

## 单 Web 控制台部署

```yaml
services:
  easytier-web:
    image: ghcr.nju.edu.cn/CertStone/easytier-web-docker:latest
    container_name: easytier-web
    restart: always
    network_mode: bridge
    ports:
      - 11211:11211
      - 22020:22020
    environment:
      # 时区
      - TZ=Asia/Shanghai
      # Web 前端默认连接的后端 API HOST
      # 默认: http://127.0.0.1:11211
      - WEB_DEFAULT_API_HOST=http://修改为你的主机:11211
      # Web 前端访问端口
      # 默认: 11211
      - WEB_PORT=11211
      # Web 后端 API 监听端口; 可与前端复用
      # 默认: 11211
      - WEB_API_PORT=11211
      # Web 管理服务 (RPC) 监听端口, Core 将通过此端口连接
      # 默认: 22020
      - WEB_SERVER_PORT=22020
      # Web 管理服务 (RPC) 协议, 可与其他节点的 -w 参数保持一致
      # 默认: udp - 可选: [udp | tcp | ws]
      - WEB_SERVER_PROTOCOL=udp
      # Web 服务日志级别 
      # 默认: warn - 可选: [off | error | warn | info | debug | trace] 
      - WEB_LOG_LEVEL=warn
    volumes:
      - ./data:/app/data
```

## ~~完整版 ( Core组网 + Web控制台 )~~ 


本仓库不维护完整版镜像