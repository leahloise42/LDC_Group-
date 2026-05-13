# LDC Group repo

Group workspace for the EPA141A course. Forked from
[Hippo-Delft-AI-Lab/epa141a](https://github.com/Hippo-Delft-AI-Lab/epa141a).

## First-time setup

You need **Miniconda** and **git** installed. Then clone this repo and run
the setup script for your OS — it creates the `epa141a` conda env and clones
the JUSTICE model into `JUSTICE-main/`.

**Mac / Linux**

```bash
git clone https://github.com/manzahn/LDC_Group-.git
cd LDC_Group-
bash setup.sh
```

**Windows (PowerShell)**

```powershell
git clone https://github.com/manzahn/LDC_Group-.git
cd LDC_Group-
.\setup.ps1
```

If PowerShell refuses to run the script, run this once and try again:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

Both scripts skip steps that are already done, so re-running them is safe.

## Daily use

```bash
conda activate epa141a
```

Then open the folder in VS Code. VS Code will prompt you to install the
recommended extensions (Python, Jupyter, GitLens, GitHub Pull Requests) —
accept. When opening a notebook, pick the **epa141a** kernel from the
top-right kernel selector.

## Git workflow

Work on a branch, not directly on `main`.

```bash
git checkout -b feature/my-thing
# ...edit, commit, push...
git push -u origin feature/my-thing
```

Then open a pull request on GitHub. Merge to `main` after review.

In **VS Code** you can do all of this from the Source Control panel
(`Ctrl+Shift+G` / `Cmd+Shift+G`):
- branch picker is in the bottom-left status bar
- stage, commit, and `Sync Changes` from the Source Control sidebar
- review and merge PRs via the **GitHub Pull Requests** extension

## Pulling updates from the course repo

The original course repo is wired up as `upstream`. To pull new course
material:

```bash
git fetch upstream
git merge upstream/main
git push origin main
```

If `upstream` is missing on your clone (`git remote -v` doesn't list it),
add it once:

```bash
git remote add upstream https://github.com/Hippo-Delft-AI-Lab/epa141a.git
```
