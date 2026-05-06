@echo off
setlocal
set "DIR=%~dp0"
where pwsh >nul 2>&1
if %ERRORLEVEL% equ 0 (
  pwsh -NoProfile -ExecutionPolicy Bypass -File "%DIR%afb_init.ps1" %*
  exit /b %ERRORLEVEL%
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%DIR%afb_init.ps1" %*
exit /b %ERRORLEVEL%
