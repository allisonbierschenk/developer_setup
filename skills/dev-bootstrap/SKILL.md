---
name: dev-bootstrap
description: Install everything a new Tableau developer needs on a fresh laptop — git, GitHub CLI, Node.js, Heroku CLI, Python, VS Code, oh-my-zsh, Salesforce CLI, Slack CLI, and Tableau CLI (tabcmd 2.0), plus Homebrew/Xcode tools on macOS. Then walks the user through GitHub authentication. Detects the OS (macOS, Windows, Linux), then offers to run all installs in one go or walk through them step-by-step with confirmation. Use when the user says things like "set up my dev environment", "install dev tools", "bootstrap my laptop", or "I just got a new computer".
---

# Developer Bootstrap

You are helping a developer install the toolchain they need to start coding. Work through the phases below in order.

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

If the user explicitly asks to upgrade ("update everything", "get me on the latest", "upgrade node"), then upgrade — but tell them the current and target version before each one, and run the OS-appropriate upgrade command:
- macOS Homebrew: `brew upgrade <pkg>` (or `brew upgrade --cask <pkg>` for casks like vscode)
- Windows winget: `winget upgrade --id <Id> -e`
- Debian/Ubuntu: `sudo apt update && sudo apt install --only-upgrade -y <pkg>` (Heroku, Slack, tabcmd, sf are not apt-managed — re-run their install scripts / `npm i -g @salesforce/cli@latest` / `pip install -U tabcmd`)
- Fedora/RHEL: `sudo dnf upgrade <pkg>`

For **already-installed tools**, just say "skipping git (2.43 already installed)" and move on.

In **step-by-step mode**: explain what you're about to install and why, then run the command.
In **run-everything mode**: run the missing ones sequentially, surfacing only errors and a brief progress note after each. Still confirm individually before oh-my-zsh (it rewrites `~/.zshrc`).

### macOS

1. **Xcode Command Line Tools** — `xcode-select --install`
   - This opens a GUI prompt. Tell the user to complete it before continuing. Verify with `xcode-select -p`.
2. **Homebrew** — `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
   - The installer prints two `eval` lines at the end specific to the user's Mac (Apple Silicon vs Intel). Run them, then `brew --version` to verify.
3. **Git + GitHub CLI** — `brew install git gh`
4. **Node.js (LTS)** — `brew install node`
5. **Heroku CLI** — `brew install heroku/brew/heroku`
6. **Python** — `brew install python` (or offer `brew install pyenv` if the user wants version management)
7. **VS Code** — `brew install --cask visual-studio-code`
8. **oh-my-zsh** — `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`
   - **Always confirm before installing**, even in run-everything mode — this rewrites the user's `~/.zshrc` and changes the default shell. The installer is interactive; warn the user it will prompt them.
9. **Salesforce CLI** — `npm install -g @salesforce/cli` (requires Node from step 4). Verify with `sf --version`.
10. **Slack CLI** — `curl -fsSL https://downloads.slack-edge.com/slack-cli/install.sh | bash`
    - The installer is interactive — it asks whether to install Deno. Tell the user to expect that prompt.
11. **Tableau CLI (tabcmd 2.0)** — `pip3 install tabcmd` (requires Python from step 6). Verify with `tabcmd --version`.

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
   - **Always confirm before installing**, even in run-everything mode — this rewrites `~/.zshrc` and changes the default shell. The installer is interactive.
8. **Salesforce CLI** — `npm install -g @salesforce/cli` (requires Node from step 3). Verify with `sf --version`.
9. **Slack CLI** — `curl -fsSL https://downloads.slack-edge.com/slack-cli/install.sh | bash`. Interactive installer.
10. **Tableau CLI (tabcmd 2.0)** — `pip3 install tabcmd` (requires Python from step 5). Verify with `tabcmd --version`.

### Linux — Fedora / RHEL

1. **Git, curl, GitHub CLI, Node** — `sudo dnf install -y git curl gh nodejs python3 python3-pip`
2. **Heroku CLI** — `curl https://cli-assets.heroku.com/install.sh | sh`
3. **VS Code** — guide them to `code` from the Microsoft repo (https://code.visualstudio.com/docs/setup/linux).
4. **zsh + oh-my-zsh** — `sudo dnf install -y zsh`, then `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`. **Always confirm before installing.**
5. **Salesforce CLI** — `npm install -g @salesforce/cli`. Verify with `sf --version`.
6. **Slack CLI** — `curl -fsSL https://downloads.slack-edge.com/slack-cli/install.sh | bash`.
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

Otherwise, tell the user: "I'm going to log you into GitHub through `gh`. It'll open your browser and ask you to paste a one-time code. Follow the prompts."

Run:

```
gh auth login
```

`gh` will ask:
- **What account?** → GitHub.com (default)
- **Preferred protocol for git operations?** → **HTTPS** (recommended — works without SSH keys; tell the user to pick it).
- **Authenticate Git with your GitHub credentials?** → **Yes**. This is the key answer that prevents Keychain pop-ups later.
- **How would you like to authenticate?** → **Login with a web browser**. `gh` will print a one-time code and open the browser. Tell the user to paste the code, click through the auth prompts, and come back to the terminal.

Wait for `gh` to print "Logged in as <username>" before continuing.

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
