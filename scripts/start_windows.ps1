Param(
	[int]$Port = 8001,
	[switch]$Reload
)

# Resolve uv from parent of current working directory (../util/uv-bin/uv.exe)
$cwdParent = Split-Path -Parent (Get-Location).Path
$uvPath = Join-Path $cwdParent "util/uv-bin/uv.exe"

# Ensure bundled uv binary exists
if (-not (Test-Path $uvPath)) {
	Write-Error "uv binary not found at $uvPath. Run scripts/download_uv_standalone.ps1 first."
	exit 1
}

# Check for Python
$py = Get-Command python -ErrorAction SilentlyContinue
if (-not $py) {
	Write-Error "Python not found. Please install Python 3.8+ from https://www.python.org/downloads/ and ensure 'python' is on PATH."
	exit 1
}

# Ensure Python 3.11.9 is available to uv
& $uvPath python install 3.11.9

# Sync dependencies using uv with Aliyun mirror
Write-Output "Syncing dependencies with uv (Aliyun mirror)..."
& $uvPath sync

# Write-Output "Starting uvicorn (host 0.0.0.0 port $Port)..."
# if ($Reload) {
#     & python -m uvicorn api.api_handler:app --host 0.0.0.0 --port $Port --reload
# } else {
#     & python -m uvicorn api.api_handler:app --host 0.0.0.0 --port $Port
# }
