# 使用官方 Node.js DevContainer 镜像（预装 Node.js 20 + Git）
FROM mcr.microsoft.com/devcontainers/javascript-node:20

# 使用国内 npm 镜像源加速安装
RUN npm config set registry https://registry.npmmirror.com && \
    npm install -g @anthropic-ai/claude-code && \
    npm config set registry https://registry.npmjs.org

# 设置默认工作目录
WORKDIR /workspaces
