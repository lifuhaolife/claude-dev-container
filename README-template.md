# Dev Container 模板使用指南

## 首次构建全局镜像

在当前目录执行：

```bash
docker build -t claude-code-global .devcontainer
```

## 在新项目中使用

### Windows

```cmd
create-devcontainer.bat D:\path\to\new-project
```

### Linux/Mac

```bash
chmod +x create-devcontainer.sh
./create-devcontainer.sh /path/to/new-project
```

## 配置说明

- 使用预构建的全局镜像 `claude-code-global`
- 自动挂载本地 Claude 认证状态
- 包含 VS Code 扩展配置

## 启动容器

在 VS Code 中打开项目后，按 `F1` 执行 "Dev Containers: Reopen in Container"
