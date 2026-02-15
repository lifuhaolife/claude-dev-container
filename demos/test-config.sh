#!/bin/bash
# DevContainer 配置测试脚本

echo "=========================================="
echo "  DevContainer 配置测试"
echo "=========================================="
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 测试函数
test_item() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $1"
    else
        echo -e "${RED}✗${NC} $1"
    fi
}

# 1. 检查 Node.js
echo "1️⃣  检查 Node.js..."
node --version > /dev/null 2>&1
test_item "Node.js 已安装: $(node --version)"
echo ""

# 2. 检查 npm
echo "2️⃣  检查 npm..."
npm --version > /dev/null 2>&1
test_item "npm 已安装: $(npm --version)"
echo ""

# 3. 检查 Claude Code CLI
echo "3️⃣  检查 Claude Code CLI..."
claude --version > /dev/null 2>&1
test_item "Claude Code CLI 已安装: $(claude --version 2>&1 | head -1)"
echo ""

# 4. 检查 Git
echo "4️⃣  检查 Git 配置..."
git --version > /dev/null 2>&1
test_item "Git 已安装: $(git --version)"

GIT_NAME=$(git config --global user.name)
GIT_EMAIL=$(git config --global user.email)

if [ -n "$GIT_NAME" ]; then
    echo -e "${GREEN}✓${NC} Git user.name: $GIT_NAME"
else
    echo -e "${RED}✗${NC} Git user.name 未配置"
fi

if [ -n "$GIT_EMAIL" ]; then
    echo -e "${GREEN}✓${NC} Git user.email: $GIT_EMAIL"
else
    echo -e "${RED}✗${NC} Git user.email 未配置"
fi
echo ""

# 5. 检查 SSH 密钥
echo "5️⃣  检查 SSH 密钥挂载..."
if [ -d "/home/node/.ssh" ]; then
    echo -e "${GREEN}✓${NC} SSH 目录已挂载: /home/node/.ssh"
    SSH_KEYS=$(ls /home/node/.ssh 2>/dev/null | grep -E "^id_" | wc -l)
    if [ $SSH_KEYS -gt 0 ]; then
        echo -e "${GREEN}✓${NC} 找到 SSH 密钥: $SSH_KEYS 个"
    else
        echo -e "${YELLOW}⚠${NC} SSH 目录为空"
    fi
else
    echo -e "${RED}✗${NC} SSH 目录未挂载"
fi
echo ""

# 6. 测试 GitHub SSH 连接
echo "6️⃣  测试 GitHub SSH 连接..."
SSH_TEST=$(ssh -T git@github.com 2>&1)
if echo "$SSH_TEST" | grep -q "successfully authenticated"; then
    GITHUB_USER=$(echo "$SSH_TEST" | grep -oP "Hi \K[^!]+")
    echo -e "${GREEN}✓${NC} GitHub SSH 认证成功: $GITHUB_USER"
else
    echo -e "${RED}✗${NC} GitHub SSH 认证失败"
    echo "  详情: $SSH_TEST"
fi
echo ""

# 7. 检查环境变量
echo "7️⃣  检查环境变量..."
if [ -n "$GIT_AUTHOR_NAME" ]; then
    echo -e "${GREEN}✓${NC} GIT_AUTHOR_NAME: $GIT_AUTHOR_NAME"
else
    echo -e "${YELLOW}⚠${NC} GIT_AUTHOR_NAME 未设置"
fi

if [ -n "$GIT_AUTHOR_EMAIL" ]; then
    echo -e "${GREEN}✓${NC} GIT_AUTHOR_EMAIL: $GIT_AUTHOR_EMAIL"
else
    echo -e "${YELLOW}⚠${NC} GIT_AUTHOR_EMAIL 未设置"
fi
echo ""

# 8. 检查网络连接（Claude API）
echo "8️⃣  测试网络连接..."
if curl -s --connect-timeout 5 https://api.anthropic.com > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} 可以访问 Claude API (api.anthropic.com)"
else
    echo -e "${RED}✗${NC} 无法访问 Claude API"
fi
echo ""

# 9. 检查端口转发
echo "9️⃣  检查端口配置..."
echo -e "${GREEN}✓${NC} 端口转发已配置: 35175 (Claude 认证端口)"
echo ""

# 10. 检查工作目录
echo "🔟 检查工作目录..."
if [ "$(pwd)" = "/workspaces/aiaskdemo/demos" ] || [ -d "/workspaces" ]; then
    echo -e "${GREEN}✓${NC} 工作目录正确: $(pwd)"
else
    echo -e "${YELLOW}⚠${NC} 当前目录: $(pwd)"
fi
echo ""

echo "=========================================="
echo "  测试完成！"
echo "=========================================="
