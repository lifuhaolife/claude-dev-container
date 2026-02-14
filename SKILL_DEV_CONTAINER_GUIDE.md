# 容器化开发环境搭建指南

## 概述

本指南详细介绍了如何使用VS Code Dev Containers和Docker搭建容器化开发环境，解决Windows环境下bash支持不友好的问题，为Claude Code等CLI工具提供统一的Linux开发环境。

## 背景

### 问题
- Windows环境对bash支持不友好
- 不同开发者环境配置不一致
- 依赖管理复杂，难以复现

### 解决方案
- 使用VS Code Dev Containers实现环境隔离
- Docker提供跨平台一致性
- 预构建镜像实现快速启动

## 架构设计

```
┌─────────────────────────────────────────────────────────────┐
│                     VS Code (Windows)                       │
├─────────────────────────────────────────────────────────────┤
│  Dev Containers Extension                                   │
│  ↓                                                          │
│  .devcontainer/devcontainer.json                            │
│  ↓                                                          │
├─────────────────────────────────────────────────────────────┤
│                   Docker Desktop (WSL2)                     │
├─────────────────────────────────────────────────────────────┤
│  claude-code-global Image                                   │
│  ├─ Ubuntu 24.04                                            │
│  ├─ Node.js 20.x+                                           │
│  ├─ Git                                                     │
│  └─ Claude Code CLI                                         │
└─────────────────────────────────────────────────────────────┘
```

## 实施步骤

### 1. 环境准备

#### 必要软件
- **Docker Desktop** (4.60+)
  - 启用WSL2后端
  - 分配至少4GB内存
  - 配置Docker镜像加速（可选）

- **VS Code** (1.85+)
  - 安装Dev Containers扩展
  - 安装Docker扩展

#### WSL2优化配置
创建 `C:\Users\lenovo\.wslconfig`：
```ini
[wsl2]
memory=4GB
processors=2
localhostForwarding=true
```

### 2. 首次构建全局镜像

#### 2.1 创建Dockerfile
**文件位置**：`.devcontainer/Dockerfile`

```dockerfile
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# 安装基础工具
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 安装 Node.js 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# 安装 Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# 设置默认工作目录
WORKDIR /workspaces
```

#### 2.2 构建全局镜像
```bash
docker build -t claude-code-global .devcontainer
```

**预期时间**：5-10分钟（首次构建）
**验证构建**：
```bash
docker images | grep claude-code-global
```

### 3. 配置Dev Container

#### 3.1 创建devcontainer.json
**文件位置**：`.devcontainer/devcontainer.json`

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

#### 3.2 配置说明
- `image`: 使用预构建的全局镜像
- `mounts`: 挂载本地Claude认证状态，避免重复登录
- `customizations`: 自动安装VS Code扩展
- `postCreateCommand`: 容器创建后执行的初始化命令

### 4. 项目模板化

#### 4.1 Windows模板脚本
**文件位置**：`create-devcontainer.bat`

```batch
@echo off
setlocal

if "%~1"=="" (
    echo Usage: %~nx0 ^<target_project_path^>
    echo Example: %~nx0 D:\Users\lenovo\projects\my-new-project
    exit /b 1
)

set TARGET_DIR=%~1
if not exist "%TARGET_DIR%" (
    mkdir "%TARGET_DIR%"
)

set DEVCONTAINER_DIR=%TARGET_DIR%\.devcontainer
if exist "%DEVCONTAINER_DIR%" (
    echo .devcontainer folder already exists in target directory.
    exit /b 0
)

mkdir "%DEVCONTAINER_DIR%"

echo {
echo   "name": "Claude Code Dev Container",
echo   "image": "claude-code-global",
echo   "customizations": {
echo     "vscode": {
echo       "extensions": [
echo         "ms-azuretools.vscode-docker",
echo         "github.copilot"
echo       ]
echo     }
echo   },
echo   "postCreateCommand": "git config --global init.defaultBranch main",
echo   "mounts": [
echo     "source=C:\\Users\\lenovo\\.claude,target=/home/vscode/.claude,type=bind"
echo   ]
echo } > "%DEVCONTAINER_DIR%\devcontainer.json"

echo.
echo Done! Dev Container template has been created in: %TARGET_DIR%
echo.
echo Next steps:
echo 1. Open the folder in VS Code
echo 2. Press F1 and select "Dev Containers: Reopen in Container"
endlocal
```

#### 4.2 Linux/Mac模板脚本
**文件位置**：`create-devcontainer.sh`

```bash
#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 <target_project_path>"
    echo "Example: $0 /home/user/projects/my-new-project"
    exit 1
fi

TARGET_DIR="$1"
mkdir -p "$TARGET_DIR"

DEVCONTAINER_DIR="$TARGET_DIR/.devcontainer"

if [ -d "$DEVCONTAINER_DIR" ]; then
    echo ".devcontainer folder already exists in target directory."
    exit 0
fi

mkdir -p "$DEVCONTAINER_DIR"

cat > "$DEVCONTAINER_DIR/devcontainer.json" << 'EOF'
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
    "source=${env:HOME}/.claude,target=/home/vscode/.claude,type=bind"
  ]
}
EOF

echo ""
echo "Done! Dev Container template has been created in: $TARGET_DIR"
echo ""
echo "Next steps:"
echo "1. Open the folder in VS Code"
echo "2. Press F1 and select 'Dev Containers: Reopen in Container'"
```

## 使用指南

### 启动Dev Container

1. 在VS Code中打开项目文件夹
2. 按 `F1` 打开命令面板
3. 输入并选择 "Dev Containers: Reopen in Container"
4. 等待容器启动（首次约30秒，后续几秒）

### 容器内开发

#### 验证环境
```bash
node --version      # 查看Node版本
claude --version    # 查看Claude Code版本
```

#### 使用Claude Code
```bash
claude
```
直接在容器内使用Claude Code CLI进行AI辅助开发

#### 常规开发操作
```bash
npm install         # 安装依赖
npm run dev         # 启动开发服务器
git status          # Git操作
```

### 文件同步

- 容器内路径：`/workspaces/<项目名>`
- 宿主机路径：项目根目录
- 文件编辑实时同步，无需手动传输

## 性能优化

### 1. 镜像加速

配置Docker镜像加速（以阿里云为例）：
```json
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn"
  ]
}
```

### 2. 缓存策略

- Docker自动缓存镜像层
- 避免频繁修改Dockerfile
- 使用`.dockerignore`排除不必要文件

### 3. WSL2优化

- 项目文件存放在WSL2文件系统
- 避免跨文件系统操作（如`/mnt/c`）
- 分配足够内存（建议4GB+）

## 故障排查

### 常见问题

#### 1. 挂载路径错误
**错误**：`bind source path does not exist`

**解决**：确保devcontainer.json中挂载路径正确：
```json
"source=C:\\Users\\lenovo\\.claude,target=/home/vscode/.claude,type=bind"
```

#### 2. 容器启动失败
**检查**：
- Docker Desktop是否运行
- WSL2是否正常工作
- 端口是否被占用

#### 3. 性能问题
**优化**：
- 使用WSL2后端
- 分配更多内存给Docker
- 项目文件存放在WSL2文件系统

### 日志查看

在VS Code中查看Dev Containers日志：
- 输出面板 → 选择 "Dev Containers"

## 扩展配置

### 添加VS Code扩展
```json
"customizations": {
  "vscode": {
    "extensions": [
      "ms-azuretools.vscode-docker",
      "github.copilot",
      "dbaeumer.vscode-eslint"
    ]
  }
}
```

### 端口转发
```json
"forwardPorts": [3000, 8080]
```

### 环境变量
```json
"containerEnv": {
  "NODE_ENV": "development"
}
```

## 最佳实践

1. **全局镜像复用**：构建一次，多个项目共享
2. **认证状态持久化**：挂载`.claude`目录
3. **轻量化基础镜像**：使用官方devcontainers镜像
4. **版本锁定**：固定Node.js、工具版本
5. **团队协作**：提交`.devcontainer`到版本控制

## 项目结构

```
project-root/
├── .devcontainer/
│   ├── devcontainer.json
│   └── Dockerfile (可选，仅首次构建需要)
├── create-devcontainer.bat
├── create-devcontainer.sh
└── README.md
```

## 参考资源

- [VS Code Dev Containers文档](https://code.visualstudio.com/docs/devcontainers/containers)
- [Docker Desktop文档](https://docs.docker.com/desktop/)
- [Claude Code CLI文档](https://docs.anthropic.com/claude-code)

## 版本历史

- v1.0 - 初始版本，基础容器化环境搭建
