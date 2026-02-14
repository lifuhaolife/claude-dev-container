# 容器内Git工具使用指南

## 基础Git配置

### 初始配置
```bash
# 设置用户信息
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# 设置默认分支名
git config --global init.defaultBranch main

# 设置编辑器
git config --global core.editor nano

# 设置差异工具
git config --global diff.tool vscode
git config --global difftool.vscode.cmd 'code --wait --diff $LOCAL $REMOTE'
```

### 配置SSH密钥

#### 方法1：从宿主机挂载SSH密钥
在 `devcontainer.json` 中添加：
```json
{
  "mounts": [
    "source=${env:USERPROFILE}\\.ssh,target=/home/vscode/.ssh,type=bind,readonly"
  ]
}
```

#### 方法2：在容器内生成新密钥
```bash
# 生成SSH密钥
ssh-keygen -t ed25519 -C "your.email@example.com"

# 查看公钥
cat ~/.ssh/id_ed25519.pub

# 添加到GitHub
# 复制公钥内容，访问：https://github.com/settings/keys
```

#### 方法3：使用SSH Agent转发
在 `devcontainer.json` 中：
```json
{
  "runArgs": [
    "--mount", "type=bind,source=/run/host-services/ssh-auth.sock,target=/run/host-services/ssh-auth.sock,readonly"
  ]
}
```

在容器内：
```bash
export SSH_AUTH_SOCK="/run/host-services/ssh-auth.sock"
```

### 配置Git代理

#### 设置代理
```bash
git config --global http.proxy http://host.docker.internal:7890
git config --global https.proxy http://host.docker.internal:7890
```

#### 取消代理
```bash
git config --global --unset http.proxy
git config --global --unset https.proxy
```

#### 查看当前代理配置
```bash
git config --global --get http.proxy
git config --global --get https.proxy
```

## 常用Git操作

### 克隆仓库
```bash
# HTTPS方式
git clone https://github.com/user/repo.git

# SSH方式（推荐）
git clone git@github.com:user/repo.git

# 克隆到指定目录
git clone git@github.com:user/repo.git my-project
```

### 分支操作
```bash
# 查看所有分支
git branch -a

# 创建新分支
git checkout -b feature/new-feature

# 切换分支
git checkout main

# 删除分支
git branch -d feature/new-feature

# 推送分支到远程
git push -u origin feature/new-feature
```

### 提交和推送
```bash
# 查看状态
git status

# 添加文件
git add .
git add file.txt

# 提交
git commit -m "Commit message"

# 推送到远程
git push

# 强制推送（谨慎使用）
git push --force
```

### 拉取和合并
```bash
# 拉取最新代码
git pull

# 拉取但不合并
git fetch

# 合并分支
git merge feature/new-feature

# 变基（推荐）
git rebase main
```

### 撤销操作
```bash
# 撤销工作区修改
git checkout -- file.txt

# 撤销暂存区
git reset HEAD file.txt

# 撤销最后一次提交
git reset --soft HEAD~1

# 硬重置到指定提交
git reset --hard commit-hash

# 回滚已推送的提交
git revert HEAD
```

### 查看历史
```bash
# 查看提交历史
git log

# 查看简洁历史
git log --oneline

# 查看文件变更历史
git log --follow file.txt

# 查看差异
git diff

# 查看已暂存的差异
git diff --staged
```

## Git别名配置

```bash
# 创建常用别名
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'
```

## 多仓库管理

### Git Submodule
```bash
# 添加子模块
git submodule add https://github.com/user/submodule.git path/to/submodule

# 初始化子模块
git submodule init

# 更新子模块
git submodule update

# 克隆包含子模块的仓库
git clone --recursive https://github.com/user/repo.git
```

### Git Worktree
```bash
# 创建工作树
git worktree add ../feature-branch feature-branch

# 列出工作树
git worktree list

# 删除工作树
git worktree remove ../feature-branch
```

## Git Hooks

### 创建Pre-commit Hook
```bash
# 创建钩子文件
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
# 运行代码检查
npm run lint
if [ $? -ne 0 ]; then
    echo "Lint failed, commit aborted"
    exit 1
fi
EOF

# 添加执行权限
chmod +x .git/hooks/pre-commit
```

## 与Claude Code集成

### 使用Claude Code辅助Git操作
```bash
# 启动Claude Code
claude

# 在Claude中执行Git命令
> 请查看当前的Git状态
> 请帮我创建一个新分支
> 请帮我提交这些更改
> 请解释最近的提交历史
```

### Git工作流建议
1. **功能分支**：每个新功能创建独立分支
2. **提交信息**：使用清晰的提交信息
3. **代码审查**：通过Pull Request进行代码审查
4. **频繁提交**：小步快跑，频繁提交
5. **保持主分支干净**：main分支始终保持可部署状态

## 常见问题解决

### SSH连接失败
```bash
# 测试SSH连接
ssh -T git@github.com

# 检查SSH密钥
ls -la ~/.ssh/

# 添加密钥到agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### 权限错误
```bash
# 修复文件权限
sudo chown -R vscode:vscode /workspaces

# 配置Git忽略权限
git config core.fileMode false
```

### 合并冲突
```bash
# 手动解决冲突后
git add conflict-file.txt
git commit

# 放弃合并
git merge --abort
```

### 凭证管理
```bash
# 存储凭证
git config --global credential.helper store

# 使用凭证助手
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=3600'
```

## 与VS Code集成

### VS Code Git操作
1. 查看Git面板（左侧源代码管理图标）
2. 点击文件查看差异
3. 输入提交信息并提交
4. 使用操作按钮推送、拉取、创建分支等

### 安装Git扩展
- GitLens：增强Git功能
- Git History：查看Git历史
- GitHub Pull Requests：管理PR
