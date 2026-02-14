# Docker 网络代理配置指南

## 配置Docker Desktop代理

### 1. Docker Desktop设置代理

1. 打开Docker Desktop
2. 进入 Settings → Resources → Proxies
3. 配置代理：
   - Manual proxy configuration
   - Web Server (HTTP): `http://127.0.0.1:7890`
   - Secure Web Server (HTTPS): `http://127.0.0.1:7890`
4. Apply & Restart

### 2. 容器内代理配置

#### 方法1：在devcontainer.json中配置
```json
{
  "name": "Claude Code Dev Container",
  "image": "claude-code-global",
  "containerEnv": {
    "HTTP_PROXY": "http://host.docker.internal:7890",
    "HTTPS_PROXY": "http://host.docker.internal:7890",
    "NO_PROXY": "localhost,127.0.0.1"
  },
  "runArgs": [
    "--network=host"
  ]
}
```

#### 方法2：在Dockerfile中配置
```dockerfile
# 设置环境变量
ENV HTTP_PROXY=http://host.docker.internal:7890
ENV HTTPS_PROXY=http://host.docker.internal:7890
ENV NO_PROXY=localhost,127.0.0.1

# 配置npm代理
RUN npm config set proxy http://host.docker.internal:7890 && \
    npm config set https-proxy http://host.docker.internal:7890

# 配置Git代理
RUN git config --global http.proxy http://host.docker.internal:7890 && \
    git config --global https.proxy http://host.docker.internal:7890
```

### 3. 临时设置代理

在容器终端中执行：
```bash
export HTTP_PROXY=http://host.docker.internal:7890
export HTTPS_PROXY=http://host.docker.internal:7890

# 测试连接
curl https://www.google.com
```

### 4. Claude CLI代理配置

在容器内设置：
```bash
export ANTHROPIC_BASE_URL=https://api.anthropic.com

# 如果需要通过代理
export HTTP_PROXY=http://host.docker.internal:7890
export HTTPS_PROXY=http://host.docker.internal:7890

# 验证
claude --version
```

## 常见问题

### 代理不生效
- 确保 `host.docker.internal` 可以访问（Windows Docker Desktop默认支持）
- 检查代理端口是否正确
- 尝试使用宿主机IP地址替代

### 连接超时
- 检查代理软件是否运行
- 确认代理允许局域网连接
- 检查防火墙设置

### Git无法连接
```bash
# 查看Git代理配置
git config --global --get http.proxy

# 取消代理
git config --global --unset http.proxy
git config --global --unset https.proxy
```
