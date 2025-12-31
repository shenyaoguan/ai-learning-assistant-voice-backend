@echo off
REM start_windows.bat [port]
SETLOCAL

REM Move to repo root (parent of scripts folder)
cd /d "%~dp0\.."

REM Use parent of current working directory as base (..\util\uv-bin\uv.exe)
set "UV_EXE=%cd%\..\util\uv-bin\uv.exe"

if not exist "%UV_EXE%" (
  echo uv binary not found at %UV_EXE%. Run scripts\download_uv_standalone.ps1 first.
  pause
  exit /b 1
)

if "%1"=="" (
  set PORT=8001
) else (
  set PORT=%1
)

where python >nul 2>nul
if errorlevel 1 (
  echo Python not found. Install Python 3.8+ and add it to PATH.
  pause
  exit /b 1
)

echo Ensuring Python 3.11.9 with uv...
"%UV_EXE%" python install 3.11.9

echo Syncing dependencies with uv (Aliyun mirror)...
"%UV_EXE%" sync

@REM echo Starting uvicorn on port %PORT%...
@REM python -m uvicorn api.api_handler:app --host 0.0.0.0 --port %PORT%

ENDLOCAL
