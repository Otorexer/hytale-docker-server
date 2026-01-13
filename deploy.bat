@echo off
title Hytale Server - Auto Release Tool
echo ========================================================
echo      HYTALE SERVER - AUTOMATIC DEPLOYMENT SCRIPT
echo ========================================================
echo.

:: --- Check for Git and Docker ---
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Git is not installed or not in PATH.
    pause
    exit /b
)
where docker >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not installed or not running.
    pause
    exit /b
)

:: --- Step 1: Push Code to GitHub ---
echo [1/3] Preparing Code Release...
set /p commit_msg="Enter commit message (Press Enter for 'Auto-update'): "
if "%commit_msg%"=="" set commit_msg=Auto-update

echo.
echo [Git] Adding files...
git add .

echo [Git] Committing changes...
git commit -m "%commit_msg%"

echo [Git] Pushing to GitHub...
git push origin main
if %errorlevel% neq 0 (
    echo [ERROR] Failed to push code to GitHub. Please check your internet or credentials.
    pause
    exit /b
)

:: --- Step 2: Build Docker Image ---
echo.
echo [2/3] Building Docker Image...
echo This may take a moment...
docker build -t ghcr.io/otorexer/hytale-server:latest .
if %errorlevel% neq 0 (
    echo [ERROR] Docker build failed.
    pause
    exit /b
)

:: --- Step 3: Push Docker Image ---
echo.
echo [3/3] Pushing Image to GitHub Container Registry...
docker push ghcr.io/otorexer/hytale-server:latest
if %errorlevel% neq 0 (
    echo [ERROR] Docker push failed. Ensure you are logged in via 'docker login ghcr.io'.
    pause
    exit /b
)

echo.
echo ========================================================
echo      SUCCESS: RELEASE DEPLOYED
echo ========================================================
echo Code pushed to repository.
echo Image pushed to: ghcr.io/otorexer/hytale-server:latest
echo.
pause