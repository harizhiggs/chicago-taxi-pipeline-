#!/usr/bin/env bash
# Install Jupyter deps and register .venv as a selectable notebook kernel.
# Run from project root: ./scripts/register_notebook_kernel.sh

set -euo pipefail

cd "$(dirname "$0")/.."
PYTHON=".venv/bin/python"

if [[ ! -x "$PYTHON" ]]; then
  echo ".venv not found. Run ./scripts/setup.sh first."
  exit 1
fi

echo "Installing notebook dependencies..."
"$PYTHON" -m pip install -r requirements-notebook.txt

echo 'Registering Jupyter kernel "Chicago Taxi (.venv)"...'
"$PYTHON" -m ipykernel install --user --name=chicago-taxi-pipeline --display-name="Chicago Taxi (.venv)"

if [[ ! -f .vscode/settings.json ]]; then
  echo "Create .vscode/settings.json and set python.defaultInterpreterPath to .venv/bin/python"
fi

echo ""
echo "Done. In the notebook kernel picker, choose: Chicago Taxi (.venv)"
