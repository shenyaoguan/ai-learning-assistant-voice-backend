Param(
	[int]$Port = 8001,
	[switch]$Reload
)

# Determine repository root (parent of scripts folder)
$repoRoot = Split-Path -Parent $PSScriptRoot

# Check for Python
$py = Get-Command python -ErrorAction SilentlyContinue
if (-not $py) {
	Write-Error "Python not found. Please install Python 3.8+ from https://www.python.org/downloads/ and ensure 'python' is on PATH."
	exit 1
}

$mirror = "https://mirrors.aliyun.com/pypi/simple"

# Ensure uv is available (install via mirror if missing)
$uv = Get-Command uv -ErrorAction SilentlyContinue
if (-not $uv) {
	Write-Output "uv not found, installing via Aliyun mirror..."
	python -m pip install --upgrade pip --index-url $mirror --trusted-host mirrors.aliyun.com
	python -m pip install uv --index-url $mirror --trusted-host mirrors.aliyun.com
}

# Ensure Python 3.11.9 is available to uv
uv python install 3.11.9

# Sync dependencies using uv with Aliyun mirror
Write-Output "Syncing dependencies with uv (Aliyun mirror)..."
uv sync --index-url $mirror --trusted-host mirrors.aliyun.com

# Write-Output "Starting uvicorn (host 0.0.0.0 port $Port)..."
# if ($Reload) {
#     & python -m uvicorn api.api_handler:app --host 0.0.0.0 --port $Port --reload
# } else {
#     & python -m uvicorn api.api_handler:app --host 0.0.0.0 --port $Port
# }
