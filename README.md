# Claude Dev Container

完整的容器化开发环境解决方案，专为Claude Code CLI设计，解决Windows环境下bash支持不友好的问题。

## 📋 目录

- [快速开始](#快速开始)
- [核心功能](#核心功能)
- [详细指南](#详细指南)
- [常见问题](#常见问题)

## 🚀 快速开始

### 环境要求

- Docker Desktop 4.60+ (启用WSL2后端)
- VS Code 1.85+
- 至少4GB内存

### 首次设置

1. **构建全局镜像**
   ```bash
   docker build -t claude-code-global .devcontainer
   ```

2. **启动开发容器**
   - 在VS Code中打开项目
   - 按 `F1` → 选择 "Dev Containers: Reopen in Container"

3. **验证环境**
   ```bash
   node --version
   claude --version
   ```

### 新项目模板

#### Windows
```cmd
create-devcontainer.bat D:\path\to\new-project
```

#### Linux/Mac
```bash
chmod +x create-devcontainer.sh
./create-devcontainer.sh /path/to/new-project
```

## ✨ 核心功能

### 1. 统一的开发环境
- Ubuntu 24.04基础系统
- Node.js 20.x
- Git版本控制
- Claude Code CLI

### 2. 网络代理支持
完整支持HTTP/HTTPS代理配置，确保Claude能够访问外部服务。

### 3. 文件挂载优化
优化的挂载配置，提高Windows下的文件访问性能。

### 4. 组件增量扩展
灵活的组件添加方式，支持Python、Java、Go等多种语言。

### 5. Git工具集成
完整的Git工具链，支持SSH、代理、多仓库管理等。

## 📚 详细指南

### [Docker网络代理配置](./docker-proxy-guide.md)
- Docker Desktop代理设置
- 容器内代理配置
- Claude CLI代理配置

### [Docker文件挂载优化](./docker-mount-guide.md)
- WSL2文件系统使用
- 挂载性能优化
- 卷持久化配置

### [容器组件增量扩展](./dockerfile-extensions.md)
- 多语言环境配置
- Dev Container Features使用
- Docker Compose多容器

### [Git工具使用指南](./git-usage-guide.md)
- Git基础配置
- SSH密钥管理
- 常用Git操作

## 🔧 配置文件说明

### `.devcontainer/devcontainer.json`
```json
{
  "name": "Claude Code Dev Container",
  "image": "claude-code-global",
  "containerEnv": {
    "HTTP_PROXY": "http://host.docker.internal:7890",
    "HTTPS_PROXY": "http://host.docker.internal:7890"
  },
  "mounts": [
    "source=C:\\Users\\lenovo\\.claude,target=/home/vscode/.claude,type=bind"
  ]
}
```

### `.devcontainer/Dockerfile`
```dockerfile
FROM mcr.microsoft.com/devcontainers/base:ubuntu

RUN apt-get update && apt-get install -y \
    curl git unzip wget && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

RUN npm install -g @anthropic-ai/claude-code

WORKDIR /workspaces
```

## ❓ 常见问题

### Q: 如何配置网络代理？
A: 参考 [Docker网络代理配置指南](./docker-proxy-guide.md)，在Docker Desktop和容器内分别配置。

### Q: 文件访问慢怎么办？
A: 参考 [Docker文件挂载优化指南](./docker-mount-guide.md)，将项目移至WSL2文件系统。

### Q: 如何添加Python支持？
A: 参考 [容器组件增量扩展指南](./dockerfile-extensions.md)，使用Features或更新Dockerfile。

### Q: Git无法连接GitHub怎么办？
A: 参考 [Git工具使用指南](./git-usage-guide.md)，配置SSH密钥或代理。

## 🤝 贡献

欢迎提交Issue和Pull Request！

## 📄 许可证

MIT License
