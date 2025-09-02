@echo off
setlocal EnableExtensions

set PORT=8080
if not "%1"=="" set PORT=%1
set SCRIPT_DIR=%~dp0

rem Keep batch ASCII-only to avoid mojibake. Delegate to PowerShell.
where /q powershell
if errorlevel 1 (
  echo PowerShell is required. Please run in PowerShell.
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%start.ps1" -Port %PORT%

endlocal
exit /b %ERRORLEVEL%
