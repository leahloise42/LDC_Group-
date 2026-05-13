#!/usr/bin/env bash
# One-shot setup for the LDC_Group- repo (Mac / Linux).
# Run from the repo root:  bash setup.sh

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

echo "==> Working in: $REPO_ROOT"

# 1. Check conda
if ! command -v conda >/dev/null 2>&1; then
  echo "ERROR: conda not found. Install Miniconda first:"
  echo "  https://docs.conda.io/en/latest/miniconda.html"
  exit 1
fi

# 2. Create the epa141a conda env (skip if it exists)
if conda env list | awk '{print $1}' | grep -qx "epa141a"; then
  echo "==> Conda env 'epa141a' already exists — skipping create."
  echo "    To rebuild it: conda env remove -n epa141a && bash setup.sh"
else
  echo "==> Creating conda env 'epa141a' from environment.yml (15-30 min)..."
  conda env create -f environment.yml
fi

# 3. Clone the JUSTICE model into JUSTICE-main/ (skip if present)
if [ -d "JUSTICE-main/.git" ] || [ -d "JUSTICE-main" ]; then
  echo "==> JUSTICE-main/ already present — skipping clone."
else
  echo "==> Cloning JUSTICE model..."
  git clone https://github.com/Hippo-Delft-AI-Lab/JUSTICE.git JUSTICE-main
fi

echo ""
echo "==> Done."
echo "Next steps:"
echo "  1. Activate the env:   conda activate epa141a"
echo "  2. Open this folder in VS Code; accept the recommended extensions prompt."
echo "  3. When opening a notebook, pick the 'epa141a' kernel (top-right)."
