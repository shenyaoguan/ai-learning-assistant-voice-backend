Param(
	[int]$Port = 8001,
	[switch]$Reload
)

function Ensure-Uv {
	if (Get-Command uv -ErrorAction SilentlyContinue) { return }
	Write-Output "uv not found in PATH. Installing via official script..."
	try { irm https://astral.sh/uv/install.ps1 | iex } catch {
		Write-Error "Failed to run official uv install script."
		exit 1
	}
	if (Get-Command uv -ErrorAction SilentlyContinue) { return }
	$uvCandidate1 = Join-Path $env:USERPROFILE ".cargo\bin\uv.exe"
	$uvCandidate2 = Join-Path $env:LOCALAPPDATA "uv\bin\uv.exe"
	if (Test-Path $uvCandidate1) { $env:PATH = "$env:PATH;$([System.IO.Path]::GetDirectoryName($uvCandidate1))"; return }
	if (Test-Path $uvCandidate2) { $env:PATH = "$env:PATH;$([System.IO.Path]::GetDirectoryName($uvCandidate2))"; return }
	Write-Error "uv not found after installation. Please restart the shell or ensure uv is on PATH."
	exit 1
}

Ensure-Uv

# Ensure Python 3.11.9 is available to uv
# uv python install 3.11.9

function Test-NvidiaGpu {
	$nv = Get-Command nvidia-smi -ErrorAction SilentlyContinue
	if (-not $nv) { return $false }
	try {
		& $nv -L | Out-Null
		return $true
	} catch {
		return $false
	}
}

# Sync dependencies using uv with Aliyun mirror
Write-Output "Syncing dependencies with uv (Aliyun mirror)..."
if (Test-NvidiaGpu) {
	Write-Output "NVIDIA GPU detected, syncing CUDA extras..."
	uv sync --extra kokoro --extra torch-cu121
} else {
	Write-Output "No NVIDIA GPU detected, syncing CPU extras..."
	uv sync --extra kokoro --extra torch-cpu
}

# Download models
Write-Output "Downloading models..."
$env:HF_ENDPOINT = "https://hf-mirror.com"
uv run .\cli.py download --model-names=kokoro
# Start the service

Write-Output "Starting service (host 0.0.0.0 port $Port)..."
uv run .\cli.py run --model-names=kokoro --port $Port

# Write-Output "Starting uvicorn (host 0.0.0.0 port $Port)..."
# if ($Reload) {
#     & python -m uvicorn api.api_handler:app --host 0.0.0.0 --port $Port --reload
# } else {
#     & python -m uvicorn api.api_handler:app --host 0.0.0.0 --port $Port
# }
