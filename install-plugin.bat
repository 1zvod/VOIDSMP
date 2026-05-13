@echo off
title VOID SMP - Plugin Installer
powershell -ExecutionPolicy Bypass -File "%~dp0install-plugin.ps1" %*
