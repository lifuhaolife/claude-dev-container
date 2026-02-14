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

echo Creating devcontainer.json...

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
echo     "source=${env:HOME}/.claude,target=/home/vscode/.claude,type=bind"
echo   ]
echo } > "%DEVCONTAINER_DIR%\devcontainer.json"

echo.
echo Done! Dev Container template has been created in: %TARGET_DIR%
echo.
echo Next steps:
echo 1. Open the folder in VS Code
echo 2. Press F1 and select "Dev Containers: Reopen in Container"
endlocal
