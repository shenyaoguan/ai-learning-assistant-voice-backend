@echo off
REM start_windows.bat [port]
SETLOCAL

REM Move to repo root (parent of scripts folder)
cd /d "%~dp0\.."

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

set PIP_MIRROR=https://mirrors.aliyun.com/pypi/simple

where uv >nul 2>nul
if errorlevel 1 (
  echo uv not found, installing via Aliyun mirror...
  python -m pip install --upgrade pip --index-url %PIP_MIRROR% --trusted-host mirrors.aliyun.com
  python -m pip install uv --index-url %PIP_MIRROR% --trusted-host mirrors.aliyun.com
)

echo Ensuring Python 3.11.9 with uv...
uv python install 3.11.9

echo Syncing dependencies with uv (Aliyun mirror)...
uv sync --index-url %PIP_MIRROR% --trusted-host mirrors.aliyun.com

@REM echo Starting uvicorn on port %PORT%...
@REM python -m uvicorn api.api_handler:app --host 0.0.0.0 --port %PORT%

ENDLOCAL
