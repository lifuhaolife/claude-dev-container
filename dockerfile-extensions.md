# 容器组件增量扩展指南

## 方式1：更新现有Dockerfile

### 添加Python支持
```dockerfile
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# 安装基础工具
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    wget \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# 安装 Node.js 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# 安装 Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# 安装常用Python包
RUN pip3 install --upgrade pip && \
    pip3 install pytest black flake8 mypy

WORKDIR /workspaces
```

### 添加Java开发环境
```dockerfile
# 安装Java 17
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

# 设置JAVA_HOME
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
```

### 添加Go开发环境
```dockerfile
# 安装Go
RUN wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz

ENV PATH="/usr/local/go/bin:${PATH}"
```

### 添加Rust开发环境
```dockerfile
# 安装Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
```

## 方式2：使用Dev Container Features（推荐）

### 更新devcontainer.json使用Features
```json
{
  "name": "Claude Code Dev Container",
  "image": "claude-code-global",
  "features": {
    "ghcr.io/devcontainers/features/python:1": {
      "version": "3.11"
    },
    "ghcr.io/devcontainers/features/java:1": {
      "version": "17",
      "installMaven": true,
      "installGradle": false
    },
    "ghcr.io/devcontainers/features/go:1": {
      "version": "1.21"
    },
    "ghcr.io/devcontainers/features/node:1": {
      "version": "20"
    },
    "ghcr.io/devcontainers/features/git:1": {},
    "ghcr.io/devcontainers/features/docker-in-docker:2": {}
  },
  "customizations": {
    "vscode": {
      "extensions": [
        "ms-azuretools.vscode-docker",
        "github.copilot",
        "ms-python.python",
        "golang.go",
        "ms-java.java-pack"
      ]
    }
  }
}
```

## 方式3：使用多层Dockerfile构建

### 创建扩展Dockerfile
```dockerfile
# dockerfile.extensions
FROM claude-code-global

# 用户名
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# 安装扩展工具
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# 安装Docker CLI
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspaces
```

### 构建扩展镜像
```bash
docker build -f dockerfile.extensions -t claude-code-extended .
```

## 方式4：postCreateCommand脚本

### 创建安装脚本
**文件**：`.devcontainer/setup.sh`
```bash
#!/bin/bash
set -e

echo "Setting up development environment..."

# 安装Python包
pip3 install --user pytest black flake8

# 安装全局npm包
npm install -g nodemon typescript @types/node

# 配置Git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 安装VS Code扩展（通过code-server）
code-server --install-extension ms-python.python

echo "Setup complete!"
```

### 在devcontainer.json中执行
```json
{
  "postCreateCommand": "bash .devcontainer/setup.sh"
}
```

## 方式5：使用Docker Compose多容器

### 创建docker-compose.yml
```yaml
version: '3.8'
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    volumes:
      - ../..:/workspaces:cached
    command: sleep infinity

  database:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: postgres
    volumes:
      - postgres-data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine

volumes:
  postgres-data:
```

### 更新devcontainer.json
```json
{
  "dockerComposeFile": "docker-compose.yml",
  "service": "app",
  "workspaceFolder": "/workspaces/${localWorkspaceFolderBasename}"
}
```

## 常用组件配置示例

### 完整的多语言开发环境
```dockerfile
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# 基础工具
RUN apt-get update && apt-get install -y \
    curl git unzip wget vim nano \
    build-essential cmake \
    && rm -rf /var/lib/apt/lists/*

# Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Python
RUN apt-get install -y python3 python3-pip python3-venv && \
    pip3 install --upgrade pip

# Java
RUN apt-get install -y openjdk-17-jdk maven

# Go
RUN wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

# Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# 通用工具
RUN npm install -g typescript nodemon
RUN pip3 install pytest black flake8 mypy

WORKDIR /workspaces
```

## 最佳实践

1. **按需扩展**：只安装项目需要的工具
2. **分层构建**：利用Docker缓存层，将变化少的指令放前面
3. **使用Features**：优先使用Dev Container Features而非手动安装
4. **版本锁定**：明确指定工具版本，避免意外更新
5. **清理缓存**：每个RUN命令后清理apt缓存

## 重建镜像

修改Dockerfile后重建：
```bash
docker build -t claude-code-global .devcontainer
```

或在VS Code中：
`F1` → "Dev Containers: Rebuild Container"
