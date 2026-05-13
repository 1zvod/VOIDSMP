@echo off
title VOID SMP Launcher
echo ============================================
echo   VOID SMP - Quick Launcher
echo ============================================
echo.
echo [1] Start MC Server
echo [2] Plugin Manager
echo [3] Exit
echo.
set /p "choice=Select: "

if "%choice%"=="1" (
    start "VOID SMP Server" cmd /c "cd /d %~dp0 && start.bat"
    echo Server starting in separate window...
    timeout /t 2 >nul
    goto :eof
)
if "%choice%"=="2" (
    start "" powershell -ExecutionPolicy Bypass -File "%~dp0plugin-manager.ps1"
    goto :eof
)
if "%choice%"=="3" exit
echo Invalid choice.
pause
