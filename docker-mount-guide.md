# Docker Desktop 文件挂载优化指南

## 挂载性能问题

Windows下Docker文件挂载性能较差，特别是当项目文件在 `/mnt/c/` 等跨文件系统路径时。

## 性能优化方案

### 1. 使用WSL2文件系统存储项目

#### 推荐做法
将项目文件存储在WSL2文件系统中，而不是Windows文件系统。

```bash
# 在WSL2中创建项目目录
mkdir -p ~/projects/claude-dev-container

# 克隆或复制项目到WSL2
cp -r /mnt/d/Users/lenovo/projects/claude/aiaskdemo ~/projects/claude-dev-container
```

#### 在VS Code中打开
1. 安装WSL扩展
2. 按 `Ctrl+Shift+P` → "WSL: Connect to WSL"
3. 打开 `~/projects/claude-dev-container`

### 2. 配置Docker Desktop共享驱动

1. Docker Desktop → Settings → Resources → File sharing
2. 确保项目所在驱动器已启用
3. 推荐使用 `cached` 一致性模式

### 3. 优化devcontainer.json配置

```json
{
  "name": "Claude Code Dev Container",
  "image": "claude-code-global",
  "workspaceMount": "source=${localWorkspaceFolder},target=/workspaces/${localWorkspaceFolderBasename},type=bind,consistency=cached",
  "workspaceFolder": "/workspaces/${localWorkspaceFolderBasename}",
  "mounts": [
    "source=C:\\Users\\lenovo\\.claude,target=/home/vscode/.claude,type=bind"
  ]
}
```

### 4. 使用命名卷（Volume）

对于node_modules等大量文件，使用Docker卷而不是绑定挂载：

```json
{
  "mounts": [
    "source=${localWorkspaceFolderBasename}-node-modules,target=/workspaces/${localWorkspaceFolderBasename}/node_modules,type=volume"
  ]
}
```

### 5. 忽略不必要的文件

创建 `.dockerignore` 减少传输量：

```
node_modules
.git
.vscode
*.log
*.tmp
.DS_Store
```

## 性能测试与监控

### 测试挂载性能

```bash
# 在容器内测试
time dd if=/dev/zero of=/workspaces/test-file bs=1M count=100

# 对比测试
time dd if=/dev/zero of=/tmp/test-file bs=1M count=100
```

### 监控磁盘IO

```bash
# Windows任务管理器 → 性能 → 磁盘
# 或使用Process Monitor查看文件访问
```

## 最佳实践

1. **优先使用WSL2文件系统**：将项目放在WSL2内，避免跨文件系统访问
2. **减少挂载文件数量**：使用 `.dockerignore` 排除不需要的文件
3. **缓存依赖文件**：将 `node_modules` 使用Docker卷挂载
4. **使用卷持久化**：数据库、缓存等使用Docker卷而非绑定挂载
5. **定期清理**：删除不必要的挂载和卷

## 故障排查

### 文件同步延迟
```json
{
  "workspaceMount": "source=${localWorkspaceFolder},target=/workspaces/${localWorkspaceFolderBasename},type=bind,consistency=delegated"
}
```

### 权限问题
```bash
# 在容器内修复权限
sudo chown -R vscode:vscode /workspaces
```

### 内存占用高
- 检查Docker Desktop内存限制（建议4GB+）
- 减少不必要的挂载
- 定期清理Docker缓存
