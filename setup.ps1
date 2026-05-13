# One-shot setup for the LDC_Group- repo (Windows PowerShell).
# Run from the repo root:  .\setup.ps1
# If PowerShell blocks the script, first run:
#   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $RepoRoot
Write-Host "==> Working in: $RepoRoot"

# 1. Check conda
if (-not (Get-Command conda -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: conda not found. Install Miniconda first:"
    Write-Host "  https://docs.conda.io/en/latest/miniconda.html"
    Write-Host "After install, open a *new* 'Anaconda Prompt' or PowerShell window and re-run this script."
    exit 1
}

# 2. Create the epa141a conda env (skip if it exists)
$envExists = (conda env list | Select-String -Pattern '^\s*epa141a\s')
if ($envExists) {
    Write-Host "==> Conda env 'epa141a' already exists - skipping create."
    Write-Host "    To rebuild it: conda env remove -n epa141a; .\setup.ps1"
} else {
    Write-Host "==> Creating conda env 'epa141a' from environment.yml (15-30 min)..."
    conda env create -f environment.yml
}

# 3. Clone the JUSTICE model into JUSTICE-main/ (skip if present)
if (Test-Path "JUSTICE-main") {
    Write-Host "==> JUSTICE-main/ already present - skipping clone."
} else {
    Write-Host "==> Cloning JUSTICE model..."
    git clone https://github.com/Hippo-Delft-AI-Lab/JUSTICE.git JUSTICE-main
}

Write-Host ""
Write-Host "==> Done."
Write-Host "Next steps:"
Write-Host "  1. Activate the env:   conda activate epa141a"
Write-Host "  2. Open this folder in VS Code; accept the recommended extensions prompt."
Write-Host "  3. When opening a notebook, pick the 'epa141a' kernel (top-right)."
