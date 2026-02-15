# Claude Dev Container

可复用的容器化开发环境配置，专为 Claude Code CLI 设计。解决 Windows 环境下 bash 支持不友好的问题，在 Dev Container 中获得完整的 Linux 开发体验。

## 环境要求

- Docker Desktop（启用 WSL2 后端）
- VS Code + [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) 扩展

## 快速开始

### 1. 在新项目中复用

将本仓库的 `.devcontainer/` 目录复制到你的项目根目录：

```bash
cp -r /path/to/this-repo/.devcontainer /path/to/your-project/
```

### 2. 启动容器

在 VS Code 中打开项目，按 `F1` → 选择 **Dev Containers: Reopen in Container**。

### 3. 验证环境

```bash
node --version   # Node.js 20
claude --version # Claude Code CLI
git --version    # Git
```

## 配置说明

### Dockerfile

基于 `mcr.microsoft.com/devcontainers/javascript-node:20` 官方镜像，预装：

- **Node.js 20** + Git
- **Claude Code CLI**（`@anthropic-ai/claude-code`）
- 使用国内 npm 镜像加速安装

### devcontainer.json

| 配置项 | 说明 |
|--------|------|
| `containerEnv` | 自动配置 Git 用户名和邮箱 |
| `forwardPorts` | 转发端口 35175 |
| `runArgs: --network=host` | 使用宿主机网络，方便代理和网络访问 |
| `mounts` | 挂载宿主机 `~/.ssh` 到容器（只读），支持 Git SSH 认证 |
| `postCreateCommand` | 容器创建后自动配置 Git 全局设置 |
| `customizations.vscode` | 预装 Docker 和 Copilot 扩展，启用 Git 智能提交和自动拉取 |

## 自定义

复用时根据需要修改 `devcontainer.json`：

- **Git 信息**：修改 `containerEnv` 中的 `GIT_AUTHOR_NAME` 和 `GIT_AUTHOR_EMAIL`
- **SSH 路径**：如果 SSH 密钥不在默认的 `%USERPROFILE%\.ssh`，修改 `mounts` 中的 `source` 路径
- **端口转发**：修改 `forwardPorts` 为你需要的端口
- **VS Code 扩展**：在 `customizations.vscode.extensions` 中添加或移除扩展

## 许可证

MIT License
