FROM mcr.microsoft.com/devcontainers/base:ubuntu

# 安装基础工具
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    wget \
    net-tools\
    telnet \
    iputils-ping\
    && rm -rf /var/lib/apt/lists/*

# 安装 Node.js 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# 安装 Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# 设置默认工作目录
WORKDIR /workspaces
