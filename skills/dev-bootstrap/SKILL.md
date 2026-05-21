---
name: dev-bootstrap
description: Install everything a new Tableau developer needs on a fresh laptop — git, GitHub CLI, Node.js, Heroku CLI, Python, VS Code, oh-my-zsh, Salesforce CLI, Slack CLI, and Tableau CLI (tabcmd 2.0), plus Homebrew/Xcode tools on macOS. Then walks the user through GitHub authentication. Detects the OS (macOS, Windows, Linux), then offers to run all installs in one go or walk through them step-by-step with confirmation. Use when the user says things like "set up my dev environment", "install dev tools", "bootstrap my laptop", or "I just got a new computer".
---

# Developer Bootstrap

You are helping a developer install the toolchain they need to start coding. Work through the phases below in order.

## Phase 0 — Operating principles (apply throughout)

Three rules that apply to **every** install and upgrade in this skill. Violating these wastes the user's time on failed commands.

### Rule 1: Detect the package manager before installing or upgrading

Tools can be installed multiple ways (brew, npm, pip, the official installer script). Running `npm install -g @salesforce/cli@latest` on a tool that was installed via `brew install sf` will fail with `EEXIST: file already exists`.

Before installing or upgrading any tool, run a quick `which <tool>` and check the prefix:
- `/opt/homebrew/bin/...` or `/usr/local/bin/...` on macOS → installed via brew. Use `brew upgrade <tool>`.
- `~/Library/Python/...` or `/usr/local/lib/python.../site-packages/...` → installed via pip. Use `pip3 install -U <tool>`.
- `~/.npm-global/` or under `node`'s global prefix → installed via npm. Use `npm i -g <tool>@latest`.
- `~/.local/bin/slack` (or wherever the install script wrote it) → installed via the tool's own script. Re-run the official install script to upgrade.

For these specific tools that have multiple install paths, **always check first**: `sf` (brew vs npm), `python3` (system vs brew vs pyenv), `node` (brew vs nvm vs system).

### Rule 2: Anticipate PATH problems for pip user-installs on macOS

`pip3 install <pkg>` on macOS using the system Python (3.9.x) writes binaries to `~/Library/Python/<version>/bin/`, which is **not on PATH by default**. The user installs `tabcmd` and then `tabcmd` doesn't work — confusing.

Two ways to handle this. Pick one based on context:

**Option A (preferred when brew Python is available):** install pip packages using brew's Python, which writes to `/opt/homebrew/bin/`:
```
brew install python   # if not already installed
pip3 install --break-system-packages tabcmd   # uses brew python
```

**Option B (when only system Python is available):** before running `pip3 install`, detect the user-pip bin dir and append it to `~/.zshrc` if it isn't there. Then run the install. Tell the user a new shell or `source ~/.zshrc` is needed for tabcmd to be on PATH:
```bash
USER_PIP_BIN="$HOME/Library/Python/$(python3 -c 'import sys; print(f\"{sys.version_info.major}.{sys.version_info.minor}\")')/bin"
if ! grep -q "$USER_PIP_BIN" ~/.zshrc 2>/dev/null; then
  echo "export PATH=\"$USER_PIP_BIN:\$PATH\"" >> ~/.zshrc
fi
pip3 install tabcmd
```

Either way, **state explicitly to the user** that tabcmd may need a new terminal tab to appear on PATH.

### Rule 3: Hand off interactive commands instead of running them via Bash

The `Bash` tool runs commands non-interactively, so commands that need real terminal interaction will fail or hang. These include:

- `brew install --cask <anything>` that triggers a sudo prompt for some casks.
- `gh auth login` (browser flow + paste a one-time code).
- The Slack CLI install script (asks "install Deno? [y/N]").
- The oh-my-zsh installer (asks to change your default shell).
- `xcode-select --install` (opens a GUI dialog).

**Do not attempt these via the Bash tool.** Instead, tell the user to run them in their Claude Code prompt with the `!` prefix, which routes the command to their actual terminal:

> Homebrew's installer needs your sudo password. Run this in your prompt:
>
> `! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
>
> Once it finishes, let me know and I'll continue.

Pause and wait for the user to confirm before continuing to the next step. Don't try, fail, then fall back — that wastes time and clutters output.

## Phase 1 — Detect the OS

Run a quick check to detect the platform. Use the `Bash` tool:

- macOS / Linux: `uname -s` (Darwin = macOS, Linux = Linux). On Linux, also check `/etc/os-release` to distinguish Debian/Ubuntu from Fedora/RHEL.
- Windows: if `uname` is unavailable, you're on native Windows PowerShell. (If the user is in WSL, treat it as Linux.)

State the detected OS to the user in one sentence.

## Phase 2 — Survey what's already installed, then ask the install mode

**Run the detection pass as a single Bash command, not one-per-tool.** The user gets one permission prompt instead of a dozen. Each line uses `||` so a missing tool reports `MISSING: <name>` instead of failing the whole script.

On macOS / Linux, run this as one Bash invocation:

```bash
echo "=== Toolchain survey ===" && \
{ git --version 2>/dev/null || echo "MISSING: git"; } && \
{ node -v 2>/dev/null && echo "node ok" || echo "MISSING: node"; } && \
{ npm -v 2>/dev/null && echo "npm ok" || echo "MISSING: npm"; } && \
{ gh --version 2>/dev/null | head -1 || echo "MISSING: gh"; } && \
{ heroku --version 2>/dev/null || echo "MISSING: heroku"; } && \
{ python3 --version 2>/dev/null || echo "MISSING: python3"; } && \
{ code --version 2>/dev/null | head -1 || echo "MISSING: code"; } && \
{ sf --version 2>/dev/null || echo "MISSING: sf"; } && \
{ slack version 2>/dev/null || echo "MISSING: slack"; } && \
{ tabcmd --version 2>/dev/null || echo "MISSING: tabcmd"; } && \
{ brew --version 2>/dev/null | head -1 || echo "MISSING: brew (macOS only)"; } && \
{ test -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" && echo "oh-my-zsh installed" || echo "MISSING: oh-my-zsh"; }
```

On Windows, run an equivalent single PowerShell command via `powershell -Command "..."`. Use `$ErrorActionPreference = 'SilentlyContinue'` and write missing-tool lines the same way.

Parse the output, then build a summary like:

> Already installed: git 2.43, node 20.11, gh 2.40
> Missing: heroku, python3, sf, slack, tabcmd, oh-my-zsh

Show that summary to the user, then determine the install mode:

**Trigger phrases that skip the question entirely.** If the user's original request matches one of these, do NOT ask — just proceed in the matching mode:

- **Run-everything mode** (no per-tool confirmation): "install everything", "install all", "set up everything", "bootstrap everything", "no confirmation", "don't ask me", "just install it", "yolo", "run it all".
- **Step-by-step mode** (confirm before each install): "step by step", "one at a time", "confirm each", "ask me first", "walk me through it", "with confirmation".
- **Update/upgrade mode**: "update everything", "upgrade everything", "update all to latest", "get me on the latest". Run upgrade commands instead of installs (see Phase 3 upgrade section). Treat this as run-everything mode for the upgrades themselves.

If the request is ambiguous (e.g. just "set up my dev environment"), ask exactly one question:

> Do you want me to **run everything missing in one pass**, or **walk through each missing step and confirm before I install it**? (I'll skip anything you already have unless you ask me to upgrade it.)

Wait for the answer. Default to step-by-step if unclear.

## Phase 3 — Run the install steps for the detected OS

**Default behavior: install only what's missing. Never silently upgrade an already-installed tool** — even in run-everything mode. Major-version bumps (e.g. Node 18 → 22, Python 3.11 → 3.12) can break the user's existing projects.

If the user explicitly asks to upgrade ("update everything", "get me on the latest", "upgrade node"), then upgrade — but tell them the current and target version before each one. **Apply Rule 1 from Phase 0**: run `which <tool>` first to determine which package manager owns the tool, then use the matching upgrade command:
- Brew-managed (most things on macOS, including `sf` if installed via `brew install heroku/brew/sf`): `brew upgrade <pkg>` or `brew upgrade --cask <pkg>`
- npm-managed globals: `npm i -g <pkg>@latest`
- pip-managed: `pip3 install -U <pkg>`
- Slack CLI (custom installer): re-run `curl -fsSL https://downloads.slack-edge.com/slack-cli/install.sh | bash`
- Heroku CLI (Linux custom installer): re-run `curl https://cli-assets.heroku.com/install.sh | sh`
- Windows winget: `winget upgrade --id <Id> -e`
- Debian/Ubuntu apt: `sudo apt update && sudo apt install --only-upgrade -y <pkg>`
- Fedora/RHEL dnf: `sudo dnf upgrade <pkg>`

**Common gotcha:** if `which sf` returns a brew prefix, do NOT run `npm i -g @salesforce/cli@latest` — npm will fail with `EEXIST: file already exists`. Run `brew upgrade sf` instead.

For **already-installed tools**, just say "skipping git (2.43 already installed)" and move on.

In **step-by-step mode**: explain what you're about to install and why, then run the command.
In **run-everything mode**: run the missing ones sequentially, surfacing only errors and a brief progress note after each. Still confirm individually before oh-my-zsh (it rewrites `~/.zshrc`).

### macOS

1. **Xcode Command Line Tools** — `xcode-select --install`
   - **Interactive (Rule 3):** opens a GUI dialog. Don't run via Bash. Hand the user `! xcode-select --install` to run in their prompt, then wait for them to confirm the dialog finished. Verify with `xcode-select -p`.
2. **Homebrew** — `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
   - **Interactive (Rule 3):** the installer asks for the user's sudo password and prints two `eval` lines specific to their Mac (Apple Silicon vs Intel). Hand the user `! /bin/bash -c "..."` to run themselves. Once it finishes, ask them to copy/run the two `eval` lines, then run `brew --version` to verify.
3. **Git + GitHub CLI** — `brew install git gh`
4. **Node.js (LTS)** — `brew install node`
5. **Heroku CLI** — `brew install heroku/brew/heroku`
6. **Python** — `brew install python` — **install this BEFORE tabcmd** so tabcmd can use brew's Python (Rule 2 Option A) and land in `/opt/homebrew/bin/`, already on PATH.
7. **VS Code** — `brew install --cask visual-studio-code`
8. **oh-my-zsh** — `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
   - **Interactive (Rule 3):** rewrites `~/.zshrc`, prompts to change default shell. Hand the user `! sh -c "$(curl ...)"` to run themselves. Always confirm before this step even in run-everything mode.
9. **Salesforce CLI** — `brew install heroku/brew/sf` (preferred — keeps `sf` brew-managed so future `update everything to latest` upgrades cleanly via `brew upgrade`). Fallback: `npm install -g @salesforce/cli`. Verify with `sf --version`.
10. **Slack CLI** — `curl -fsSL https://downloads.slack-edge.com/slack-cli/install.sh | bash`
    - **Interactive (Rule 3):** asks "install Deno? [y/N]". Hand the user the `!`-prefixed command to run themselves.
11. **Tableau CLI (tabcmd 2.0)** — `pip3 install tabcmd`. **Apply Rule 2** before running:
    - If brew Python is installed (step 6 above ran): `which pip3` should return `/opt/homebrew/bin/pip3`. Safe to run `pip3 install tabcmd` and `tabcmd` will be on PATH.
    - If only system Python is available: append the user-pip bin dir to `~/.zshrc` first (see Rule 2 Option B), then run the install, then tell the user to open a new terminal tab.
    - Verify with `tabcmd --version` (or `~/Library/Python/3.9/bin/tabcmd --version` if PATH update is pending a new shell).

### Windows (PowerShell, not WSL)

Run each via the `Bash` tool by invoking `powershell -Command "..."`, or instruct the user to paste in PowerShell if Bash is unavailable.

1. **Git** — `winget install --id Git.Git -e`
2. **GitHub CLI** — `winget install --id GitHub.cli -e`
3. **Node.js (LTS)** — `winget install --id OpenJS.NodeJS.LTS -e`
4. **Heroku CLI** — `winget install --id Heroku.HerokuCLI -e`
5. **Python** — `winget install --id Python.Python.3.12 -e`
6. **VS Code** — `winget install --id Microsoft.VisualStudioCode -e`
7. **oh-my-zsh** — Skip on native Windows. Tell the user oh-my-zsh requires zsh, which isn't standard on Windows; they'd need WSL2 (which uses the Linux flow) or Git Bash with zsh. Don't try to install it on plain PowerShell.
8. **Salesforce CLI** — `npm install -g @salesforce/cli` (requires Node from step 3). Verify with `sf --version`.
9. **Slack CLI** — `irm https://downloads.slack-edge.com/slack-cli/install-windows.ps1 | iex` (run in PowerShell). The installer is interactive.
10. **Tableau CLI (tabcmd 2.0)** — `pip install tabcmd` (requires Python from step 5). Verify with `tabcmd --version`.

After installs, remind the user to **close and reopen PowerShell** so the new tools are on PATH.

If the user is in WSL2, switch to the Linux flow inside their WSL shell.

### Linux — Debian / Ubuntu

1. `sudo apt update`
2. **Git, curl, GitHub CLI** — `sudo apt install -y git curl gh`
3. **Node.js (LTS via NodeSource)** —
   ```
   curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
   sudo apt install -y nodejs
   ```
4. **Heroku CLI** — `curl https://cli-assets.heroku.com/install.sh | sh`
5. **Python** — `sudo apt install -y python3 python3-pip python3-venv`
6. **VS Code** — `sudo snap install code --classic` (or guide them to the .deb if snap isn't available)
7. **zsh + oh-my-zsh** — `sudo apt install -y zsh`, then `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`.
   - **Interactive (Rule 3):** rewrites `~/.zshrc`, prompts to change default shell. Hand the user `! sh -c "$(curl ...)"` to run themselves. Always confirm before this step even in run-everything mode.
8. **Salesforce CLI** — `npm install -g @salesforce/cli` (requires Node from step 3). Verify with `sf --version`.
9. **Slack CLI** — `curl -fsSL https://downloads.slack-edge.com/slack-cli/install.sh | bash`.
   - **Interactive (Rule 3):** asks "install Deno? [y/N]". Hand the user the `!`-prefixed command to run themselves.
10. **Tableau CLI (tabcmd 2.0)** — `pip3 install tabcmd` (requires Python from step 5). Verify with `tabcmd --version`.

### Linux — Fedora / RHEL

1. **Git, curl, GitHub CLI, Node** — `sudo dnf install -y git curl gh nodejs python3 python3-pip`
2. **Heroku CLI** — `curl https://cli-assets.heroku.com/install.sh | sh`
3. **VS Code** — guide them to `code` from the Microsoft repo (https://code.visualstudio.com/docs/setup/linux).
4. **zsh + oh-my-zsh** — `sudo dnf install -y zsh`, then `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`.
   - **Interactive (Rule 3):** rewrites `~/.zshrc`, prompts to change default shell. Hand the user `! sh -c "$(curl ...)"` to run themselves. Always confirm before this step even in run-everything mode.
5. **Salesforce CLI** — `npm install -g @salesforce/cli`. Verify with `sf --version`.
6. **Slack CLI** — `curl -fsSL https://downloads.slack-edge.com/slack-cli/install.sh | bash`.
   - **Interactive (Rule 3):** asks "install Deno? [y/N]". Hand the user the `!`-prefixed command to run themselves.
7. **Tableau CLI (tabcmd 2.0)** — `pip3 install tabcmd`. Verify with `tabcmd --version`.

## Phase 4 — Verify the toolchain and print a status report

**Run all verifications as a single Bash command, not one-per-tool** — same approach as Phase 2. The user should see one permission prompt, not twelve.

Reuse the exact same single-command block from Phase 2 (the `echo "=== Toolchain survey ===" && { git --version ... }` chain). Capture the output and parse it into a status table.

**Format the report as a table** so the user can see everything at a glance. Use ✓ for installed and ✗ for missing/errored. Example:

```
Toolchain status
─────────────────────────────────────────────
✓  git           2.43.0
✓  node          v20.11.1
✓  npm           10.2.4
✓  gh            2.40.1
✓  heroku        9.4.0
✓  python3       3.12.2
✓  code          1.86.0
✓  sf            @salesforce/cli/2.27.6
✗  slack         not found
✓  tabcmd        2.0.13
✓  oh-my-zsh     installed
─────────────────────────────────────────────
10 of 11 installed. 1 missing: slack
```

After the table, if anything is missing or errored:
1. Tell the user which tools failed.
2. Offer to re-run those specific installs.
3. Mention the most common macOS gotcha if relevant: Homebrew prints two `eval` lines after install — if those weren't run, `brew`-installed tools won't be on PATH yet. Suggest opening a new terminal tab or running the two `eval` lines from Phase 3 step 2.

If everything passes, say so plainly: "All 11 tools verified. Now let's get you authenticated with GitHub."

## Phase 5 — GitHub authentication walkthrough

After tool installs are verified, walk the user through GitHub setup so `git push`, `git pull`, and `gh` commands work without macOS Keychain pop-ups or password re-prompts. **Don't skip this phase** — most new-laptop frustration comes from broken git auth, not missing tools.

Run these steps in order, talking the user through each one. Pause and explain when waiting on browser interaction.

### Step 5.1 — Configure git identity

Check whether git already knows who they are:

```
git config --global user.name
git config --global user.email
```

If either is empty, ask the user (in plain terms): "What name should show up on your commits?" and "What email do you use on GitHub?" Then run, substituting their actual values:

```
git config --global user.name "Their Real Name"
git config --global user.email "their.email@example.com"
```

Never leave placeholder text like `"..."` or `"<name>"` in the command.

### Step 5.2 — Authenticate GitHub CLI

Run `gh auth status` first. If it reports they're already logged in, skip to step 5.3.

Otherwise, **`gh auth login` is interactive (Rule 3)** — it opens a browser flow and asks the user to paste a one-time code. Don't run it via the Bash tool; hand it off:

> Run this in your prompt so it can drive your terminal:
>
> `! gh auth login`
>
> Pick the answers below as it prompts you, then let me know when it prints "Logged in as <username>".

`gh` will ask:
- **What account?** → GitHub.com (default)
- **Preferred protocol for git operations?** → **HTTPS** (recommended — works without SSH keys; tell the user to pick it).
- **Authenticate Git with your GitHub credentials?** → **Yes**. This is the key answer that prevents Keychain pop-ups later.
- **How would you like to authenticate?** → **Login with a web browser**. `gh` will print a one-time code and open the browser. Tell the user to paste the code, click through the auth prompts, and come back to the terminal.

Wait for the user to confirm `gh` printed "Logged in as <username>" before continuing.

### Step 5.3 — Set gh as the git credential helper

This is what stops the macOS Keychain pop-up from appearing on every `git push`. Run:

```
gh auth setup-git
```

This tells git: "use `gh`'s stored credentials, not Keychain." After this, `git push` and `git pull` to GitHub repos work silently.

### Step 5.4 — Verify auth end-to-end

Run a quick check so the user sees it working:

```
gh auth status
gh repo list --limit 3
```

If `gh repo list` prints repos without prompting for a password, auth is set up correctly. Tell the user: "You're authenticated with GitHub. `git push` and `git pull` will work without password prompts from here on."

### Step 5.5 — Final wrap-up

Summarize for the user:
- Which tools were already installed vs. newly installed (from the Phase 4 status table).
- That GitHub auth is configured and working.
- Any manual steps still pending (Xcode GUI prompt, PowerShell restart on Windows, etc.).
- Suggest one starter command they can try now: `gh repo clone <some-repo>` or just `gh repo list`.

## Notes

- Never use `sudo` on macOS for Homebrew — Homebrew refuses to run as root.
- Never modify the user's shell rc files without asking.
- If a command needs `sudo` on Linux, mention it before running so the user isn't surprised by the password prompt.
- If a tool is already installed but outdated, ask before upgrading — don't surprise them with a major version bump.
