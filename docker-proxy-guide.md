# Docker 网络代理配置指南

## 最简单方案（推荐）

### 方案：宿主机代理 + Docker Desktop配置

这是最简单且最有效的方案，只需要在Docker Desktop层面配置代理，所有容器自动继承。

### 具体步骤

#### 1. Docker Desktop配置代理（一次配置，永久生效）

1. 打开Docker Desktop
2. 点击右上角齿轮图标进入 **Settings**
3. 选择左侧 **Resources** → **Proxies**
4. 选择 **Manual proxy configuration**
5. 配置代理：
   - **Web Server (HTTP)**: `http://127.0.0.1:7890`
   - **Secure Web Server (HTTPS)**: `http://127.0.0.1:7890`
   - **Bypass for these hosts**: `localhost,127.0.0.1`
6. 点击 **Apply & Restart**

#### 2. 验证代理是否生效

在容器内运行：
```bash
curl https://www.google.com
```

如果返回HTML内容，说明代理配置成功。

#### 3. 完整的devcontainer.json（无需额外配置）

```json
{
  "name": "Claude Code Dev Container",
  "image": "claude-code-global",
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-azuretools.vscode-docker",
        "github.copilot"
      ]
    }
  },
  "postCreateCommand": "git config --global init.defaultBranch main",
  "mounts": [
    "source=C:\\Users\\lenovo\\.claude,target=/home/vscode/.claude,type=bind"
  ]
}
```

**无需添加任何 `containerEnv` 或 `runArgs`！**

### 为什么这个方案最简单？

1. **配置一次，永久生效**：只在Docker Desktop配置一次，所有新创建的容器自动使用
2. **无需修改代码**：不需要在 `devcontainer.json` 或 `Dockerfile` 中添加任何代理相关配置
3. **自动继承**：容器内的所有工具（npm、git、curl等）自动使用代理
4. **易于管理**：在Docker Desktop中修改代理配置，所有容器立即生效
5. **跨项目通用**：所有使用Docker Desktop的项目都能使用这个配置

### 工作原理

Docker Desktop会将宿主机的代理设置传递给容器内的环境变量：
- `HTTP_PROXY`
- `HTTPS_PROXY`
- `NO_PROXY`

容器内的所有网络请求会自动通过这些环境变量路由到代理。

---

## 其他方案对比

### 方案2：在devcontainer.json中配置代理

**优点**：项目级配置，不会影响其他容器
**缺点**：需要在每个项目的 `devcontainer.json` 中重复配置

```json
{
  "containerEnv": {
    "HTTP_PROXY": "http://host.docker.internal:7890",
    "HTTPS_PROXY": "http://host.docker.internal:7890",
    "NO_PROXY": "localhost,127.0.0.1"
  }
}
```

### 方案3：在Dockerfile中配置代理

**优点**：镜像包含代理配置
**缺点**：每次构建镜像时需要重新配置，不够灵活

```dockerfile
ENV HTTP_PROXY=http://host.docker.internal:7890
ENV HTTPS_PROXY=http://host.docker.internal:7890
```

### 方案4：在容器内临时设置代理

**优点**：临时使用，不影响其他
**缺点**：每次启动容器都需要手动设置，容器重启后失效

```bash
export HTTP_PROXY=http://host.docker.internal:7890
export HTTPS_PROXY=http://host.docker.internal:7890
```

---

## 故障排查

### 1. 代理不生效

#### 检查Docker Desktop代理设置
```bash
# 在容器内检查环境变量
echo $HTTP_PROXY
echo $HTTPS_PROXY
```

如果没有输出，说明Docker Desktop代理配置未生效。

#### 检查代理软件是否运行
确保你的代理软件（如Clash、V2Ray等）正在运行。

#### 测试代理连接
```bash
# 测试宿主机代理是否可访问
curl http://127.0.0.1:7890

# 测试外部连接
curl https://www.google.com
```

### 2. 特定工具无法连接

#### Git代理问题
```bash
# 取消Git代理设置（使用系统代理）
git config --global --unset http.proxy
git config --global --unset https.proxy
```

#### npm代理问题
```bash
# 取消npm代理设置（使用系统代理）
npm config delete proxy
npm config delete https-proxy
```

### 3. 速度慢

#### 检查代理性能
- 尝试更换代理节点
- 检查代理软件是否支持多线程
- 临时关闭代理测试速度

#### 使用缓存
```bash
# 清理Docker缓存
docker system prune -a

# 清理npm缓存
npm cache clean --force
```

---

## 最佳实践

### 1. 优先使用Docker Desktop代理配置
这是最简单、最可靠的方式。

### 2. 按需配置项目级代理
只有在特定项目需要特殊代理设置时，才在 `devcontainer.json` 中配置。

### 3. 避免重复配置
不要同时在Docker Desktop和项目中配置代理，可能导致冲突。

### 4. 定期测试
定期测试容器内的网络连接，确保代理配置正常工作。

### 5. 文档化代理信息
将代理配置信息记录在项目文档中，方便团队成员参考。

---

## 快速参考

### Docker Desktop代理配置路径
`Docker Desktop` → `Settings` → `Resources` → `Proxies`

### 常用代理端口
- Clash: `7890`
- V2Ray: `10808`
- Shadowsocks: `1080`

### 验证命令
```bash
# 测试代理
curl https://www.google.com

# 查看环境变量
env | grep -i proxy
```

### 清除代理设置
```bash
# 在Docker Desktop中关闭代理设置
# 或在容器内
unset HTTP_PROXY
unset HTTPS_PROXY
```

---

## 总结

**推荐使用Docker Desktop代理配置**，因为：
- ✅ 配置一次，永久生效
- ✅ 无需修改任何代码
- ✅ 所有容器自动使用
- ✅ 易于管理和维护
- ✅ 跨项目通用

这是最简单、最可靠的容器代理设置方案。
