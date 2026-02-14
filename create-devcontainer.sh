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

echo "Creating devcontainer.json..."

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
