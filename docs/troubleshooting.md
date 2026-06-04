# Troubleshooting

Common setup issues when cloning and running this project on a new machine.

## Clone path on Windows

If `python -m venv .venv` prints warnings like **"Unable to copy ... to ... python.exe"**, the project path may contain **spaces** or sit in a synced folder (OneDrive, etc.) that locks files.

**Fix:** Clone to a short path without spaces, for example:

```text
C:\dev\chicago-taxi-pipeline
```

Then re-run setup. Close any process using `.venv\Scripts\python.exe` (terminals, Jupyter kernels) before recreating the venv.

## PowerShell script execution disabled

If you see **"running scripts is disabled on this system"** when running `setup.ps1`:

**Option A — use the batch wrapper (easiest):**

```cmd
scripts\setup.bat
```

**Option B — bypass for one command:**

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\setup.ps1
```

**Option C — manual setup (no `.ps1` at all):**

```cmd
python -m venv .venv
.venv\Scripts\python.exe -m pip install --upgrade pip
.venv\Scripts\python.exe -m pip install -r requirements.txt
.venv\Scripts\python.exe -m pip install "duckdb>=1.0.0,<2.0.0"
.venv\Scripts\python.exe -c "import duckdb; print(duckdb.__version__)"
.venv\Scripts\python.exe src\run_pipeline.py --generate
.venv\Scripts\python.exe src\export_for_bi.py
.venv\Scripts\python.exe scripts\verify.py
```

Note: `Activate.ps1` is also blocked by default policy — use `.venv\Scripts\python.exe` and `.venv\Scripts\pip.exe` directly instead of activating.

## Virtual environment and pip

| Symptom | Fix |
|---------|-----|
| `ModuleNotFoundError: duckdb` when running `verify.py` | Run `.\scripts\setup.ps1` first (creates venv + installs deps + runs pipeline). Then use `.\.venv\Scripts\python.exe scripts\verify.py` or activate `.venv` before `python scripts\verify.py` |
| `ModuleNotFoundError: duckdb` (general) | Activate `.venv` and run `pip install -r requirements.txt` |
| venv created but `python` is wrong interpreter | Use full path: `.venv\Scripts\python.exe` (Windows) or `.venv/bin/python` (macOS/Linux) |
| venv copy warnings on Windows | See clone path section above |

## Jupyter notebook

The notebook requires the pipeline to run first, then notebook dependencies and a registered kernel.

**Windows (recommended):**

```cmd
scripts\register_notebook_kernel.bat
```

**Manual:**

```cmd
.venv\Scripts\python.exe -m pip install -r requirements-notebook.txt
.venv\Scripts\python.exe -m ipykernel install --user --name=chicago-taxi-pipeline --display-name="Chicago Taxi (.venv)"
```

Copy [`.vscode/settings.json.example`](../.vscode/settings.json.example) to `.vscode/settings.json` if Cursor does not offer `.venv` under Python Environments.

### Cannot select .venv as kernel

1. Run `scripts\register_notebook_kernel.bat` (installs `ipykernel` + registers the kernel).
2. Open `notebooks/exploration.ipynb`.
3. Kernel picker → **Chicago Taxi (.venv)**.
4. If missing: `Ctrl+Shift+P` → **Notebook: Select Notebook Kernel** → **Chicago Taxi (.venv)** or **Python Environments** → path ending in `.venv\Scripts\python.exe`.
5. `Ctrl+Shift+P` → **Developer: Reload Window**, then pick the kernel again.

Confirm the Jupyter extension is enabled in Cursor/VS Code (Python + Jupyter).

### Cells stuck on "pending"

Usually a disconnected or duplicate kernel:

1. `Ctrl+Shift+P` → **Notebook: Select Notebook Kernel** → choose `.venv`
2. **Restart Kernel**, then **Run All**
3. Close extra terminal/Jupyter processes if needed

### VS Code / Cursor interpreter

Copy the example workspace settings after creating the venv:

```bash
# Windows (PowerShell)
Copy-Item .vscode/settings.json.example .vscode/settings.json
```

Adjust the path in `settings.json` for macOS/Linux (`bin/python` instead of `Scripts/python.exe`).

## Pipeline order

Run steps in this order:

1. `python src/run_pipeline.py --generate` — sample CSV + DuckDB warehouse
2. `python src/export_for_bi.py` — Parquet in `data/processed/`
3. Notebook or Metabase (optional)

Verify everything with:

```bash
python scripts/verify.py
```

## Docker and Metabase

Metabase is optional. See [metabase-local-setup.md](metabase-local-setup.md).

| Symptom | Fix |
|---------|-----|
| `docker: command not found` after installing Docker Desktop | Open a **new** terminal (PATH updates after install). Or add Docker's bin folder to PATH and start Docker Desktop from the Start menu. |
| Docker Desktop not running | Start **Docker Desktop** and wait until the engine is ready before `docker run`. |
| Container name already in use | `docker rm -f metabase` then re-run the `docker run` command |
| Port 3000 in use | Use `-p 3001:3000` and open http://localhost:3001 |
| Empty charts in Metabase | Re-run `python src/export_for_bi.py` after the pipeline |

### Docker Desktop install choice (Windows)

For a personal dev machine, **per-user installation** is the usual choice. Use **all users** only if IT requires a machine-wide install.

## Raw data and warehouse

| Symptom | Fix |
|---------|-----|
| `Raw CSV not found` | Run with `--generate` or place your file at `data/raw/taxi_trips_2024_01.csv` |
| `Warehouse not found` (verify script) | Run `python src/run_pipeline.py --generate` |
| Parquet files missing | Run `python src/export_for_bi.py` after the pipeline |

## Still stuck?

1. Confirm Python 3.10+: `python --version`
2. Run `python scripts/verify.py` and fix each reported error
3. Check [README.md](../README.md) quick start and [metabase-local-setup.md](metabase-local-setup.md)
