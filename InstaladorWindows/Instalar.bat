@echo off
title Instalador - ERP Marmoraria
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "setup.ps1"
if %errorlevel% neq 0 (
    echo.
    echo Pressione qualquer tecla para sair...
    pause >nul
)
