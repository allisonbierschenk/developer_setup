---
name: dev-bootstrap
description: Install everything a new Tableau developer needs on a fresh laptop — git, GitHub CLI, Node.js, Heroku CLI, Python, VS Code, oh-my-zsh, Salesforce CLI, and Slack CLI, plus Homebrew/Xcode tools on macOS. Then walks the user through GitHub authentication. Detects the OS (macOS, Windows, Linux), then offers to run all installs in one go or walk through them step-by-step with confirmation. Use when the user says things like "set up my dev environment", "install dev tools", "bootstrap my laptop", or "I just got a new computer".
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

### Rule 2: Hand off interactive commands instead of running them via Bash

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

On macOS / Linux, run this as one Bash invocation. It prints a colored, padded table using ANSI escape codes — green ✓ for installed tools, red ✗ for missing ones — so the user can scan it instantly:

```bash
G=$'\033[32m'; R=$'\033[31m'; C=$'\033[36m'; D=$'\033[2m'; B=$'\033[1m'; X=$'\033[0m'; \
row(){ local name=$1 ver=$2; if [ -n "$ver" ]; then printf "  ${G}✓${X} ${B}%-12s${X} ${C}%s${X}\n" "$name" "$ver"; else printf "  ${R}✗${X} ${B}%-12s${X} ${D}not found${X}\n" "$name"; fi; }; \
printf "\n${B}Toolchain status${X}\n${D}─────────────────────────────────────────────${X}\n"; \
row git       "$(git --version 2>/dev/null | awk '{print $3}')"; \
row node      "$(node -v 2>/dev/null)"; \
row npm       "$(npm -v 2>/dev/null)"; \
row gh        "$(gh --version 2>/dev/null | head -1 | awk '{print $3}')"; \
row heroku    "$(heroku --version 2>/dev/null | awk '{print $1}')"; \
row python3   "$(python3 --version 2>/dev/null | awk '{print $2}')"; \
row code      "$(code --version 2>/dev/null | head -1)"; \
row sf        "$(sf --version 2>/dev/null | awk '{print $1}')"; \
row slack     "$(slack version 2>/dev/null | awk '{print $NF}')"; \
row brew      "$(brew --version 2>/dev/null | head -1 | awk '{print $2}')"; \
row oh-my-zsh "$([ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ] && echo installed)"; \
printf "${D}─────────────────────────────────────────────${X}\n\n"
```

Notes for parsing the output:
- A green ✓ followed by a version means the tool is installed.
- A red ✗ followed by `not found` means it's missing — use that to build the install list.
- The colors render in the user's terminal *and* in your tool output, so you don't need to reformat into a separate table afterward — just point at it and tell the user the count (e.g. "9 of 11 installed, missing: slack, oh-my-zsh").

On Windows, run an equivalent single PowerShell command via `powershell -Command "..."`. Use `$ErrorActionPreference = 'SilentlyContinue'` and write missing-tool lines the same way.

Parse the output, then build a summary like:

> Already installed: git 2.43, node 20.11, gh 2.40
> Missing: heroku, python3, sf, slack, oh-my-zsh

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
   - **Interactive (Rule 2):** opens a GUI dialog. Don't run via Bash. Hand the user `! xcode-select --install` to run in their prompt, then wait for them to confirm the dialog finished. Verify with `xcode-select -p`.
2. **Homebrew** — `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
   - **Interactive (Rule 2):** the installer asks for the user's sudo password and prints two `eval` lines specific to their Mac (Apple Silicon vs Intel). Hand the user `! /bin/bash -c "..."` to run themselves. Once it finishes, ask them to copy/run the two `eval` lines, then run `brew --version` to verify.
3. **Git + GitHub CLI** — `brew install git gh`
4. **Node.js (LTS)** — `brew install node`
5. **Heroku CLI** — `brew install heroku/brew/heroku`
6. **Python** — `brew install python`
7. **VS Code** — `brew install --cask visual-studio-code`
8. **oh-my-zsh** — `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
   - **Interactive (Rule 2):** rewrites `~/.zshrc`, prompts to change default shell. Hand the user `! sh -c "$(curl ...)"` to run themselves. Always confirm before this step even in run-everything mode.
9. **Salesforce CLI** — `brew install heroku/brew/sf` (preferred — keeps `sf` brew-managed so future `update everything to latest` upgrades cleanly via `brew upgrade`). Fallback: `npm install -g @salesforce/cli`. Verify with `sf --version`.
10. **Slack CLI** — `curl -fsSL https://downloads.slack-edge.com/slack-cli/install.sh | bash`
    - **Interactive (Rule 2) — DO NOT RUN VIA BASH.** The installer prompts "install Deno? [y/N]" and "install slack-cli to /usr/local/bin? [y/N]". If you run it through the Bash tool, both prompts time out, the script exits silently, and **`slack` never lands on PATH**. The user thinks it installed when nothing happened. Always hand it off:
      > Slack CLI's installer needs to ask you a couple of questions. Run this in your prompt:
      >
      > `! curl -fsSL https://downloads.slack-edge.com/slack-cli/install.sh | bash`
      >
      > Answer **y** to both prompts. Tell me when it prints "Slack CLI installed".
    - After they confirm, verify with `slack version`. If it's still not found, the most common cause is the installer wrote to `~/.slack/bin/slack` but `~/.slack/bin` isn't on PATH — append it to `~/.zshrc` and tell the user to open a new terminal tab.

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
   - **Interactive (Rule 2):** rewrites `~/.zshrc`, prompts to change default shell. Hand the user `! sh -c "$(curl ...)"` to run themselves. Always confirm before this step even in run-everything mode.
8. **Salesforce CLI** — `npm install -g @salesforce/cli` (requires Node from step 3). Verify with `sf --version`.
9. **Slack CLI** — `curl -fsSL https://downloads.slack-edge.com/slack-cli/install.sh | bash`.
   - **Interactive (Rule 2) — DO NOT RUN VIA BASH.** Same issue as macOS: the installer asks "install Deno?" and "install slack-cli?", both timing out under the Bash tool and silently failing. Hand off the `!`-prefixed command and tell the user to answer **y** to both prompts, then verify with `slack version`.

### Linux — Fedora / RHEL

1. **Git, curl, GitHub CLI, Node** — `sudo dnf install -y git curl gh nodejs python3 python3-pip`
2. **Heroku CLI** — `curl https://cli-assets.heroku.com/install.sh | sh`
3. **VS Code** — guide them to `code` from the Microsoft repo (https://code.visualstudio.com/docs/setup/linux).
4. **zsh + oh-my-zsh** — `sudo dnf install -y zsh`, then `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`.
   - **Interactive (Rule 2):** rewrites `~/.zshrc`, prompts to change default shell. Hand the user `! sh -c "$(curl ...)"` to run themselves. Always confirm before this step even in run-everything mode.
5. **Salesforce CLI** — `npm install -g @salesforce/cli`. Verify with `sf --version`.
6. **Slack CLI** — `curl -fsSL https://downloads.slack-edge.com/slack-cli/install.sh | bash`.
   - **Interactive (Rule 2) — DO NOT RUN VIA BASH.** Same issue as macOS: the installer asks "install Deno?" and "install slack-cli?", both timing out under the Bash tool and silently failing. Hand off the `!`-prefixed command and tell the user to answer **y** to both prompts, then verify with `slack version`.

## Phase 4 — Verify the toolchain and print a status report

**Re-run the exact same colored-table command from Phase 2** — one Bash invocation, one permission prompt. The output is already a formatted, color-coded table; don't reformat it into a different table afterward (that just duplicates the info and loses the colors).

After the table prints, summarize in one line: how many installed, which (if any) are missing. Example:

> 9 of 11 installed. Missing: slack, oh-my-zsh.

If anything is missing or errored:
1. Tell the user which tools failed.
2. Offer to re-run those specific installs.
3. Mention the most common macOS gotcha if relevant: Homebrew prints two `eval` lines after install — if those weren't run, `brew`-installed tools won't be on PATH yet. Suggest opening a new terminal tab or running the two `eval` lines from Phase 3 step 2.

If everything passes, say so plainly: "All tools verified. Now let's get you authenticated with GitHub."

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

Otherwise, **`gh auth login` is interactive (Rule 2)** — it opens a browser flow and asks the user to paste a one-time code. Don't run it via the Bash tool; hand it off:

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
