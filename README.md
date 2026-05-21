# developer_setup

A Claude Code skill that installs everything a developer needs on a laptop — git, GitHub CLI, Node.js, Heroku CLI, Python, VS Code, oh-my-zsh, Salesforce CLI, and Slack CLI. Then it walks you through GitHub authentication so `git push` and `git pull` work without password pop-ups.

Works on macOS, Windows, and Linux.

---

## How it works

Claude Code looks for skills in a folder inside your home directory:

- macOS / Linux: `~/.claude/skills/` (the `~` is your home directory)
- Windows: `$HOME\.claude\skills\` (`$HOME` resolves to `C:\Users\YourUsername` automatically)

If a folder contains a file called `SKILL.md`, Claude Code uses it. 

Your job is to get our `SKILL.md` into `~/.claude/skills/dev-bootstrap/`. The steps below do that for you.

---

## Step 1 — Install Claude Code

Claude Code is the app that runs the skill. Install it from the team Slack canvas before continuing.

---

## Step 2 — Download the skill onto your laptop

This downloads `SKILL.md` from this repo and saves it to `~/.claude/skills/dev-bootstrap/SKILL.md` — the folder Claude Code reads from. Run once per laptop.

**Open your default terminal app:**
- macOS: open **Terminal** (Cmd + Space, type `Terminal`, Enter).
- Windows: open **PowerShell** (Windows key, type `PowerShell`, Enter).
- Linux: open your usual terminal.

**Then copy the single command line below for your OS, paste it at the prompt, and press Enter.** Don't type anything else first — no `bash`, no `cd`, nothing. Copy only the line in the gray box; do not include the triple backticks or the word `bash`/`powershell` above it.

**macOS or Linux** — copy this one line:
```
curl -fsSL https://raw.githubusercontent.com/allisonbierschenk/developer_setup/main/install.sh | bash
```

**Windows (PowerShell)** — copy this one line:
```
irm https://raw.githubusercontent.com/allisonbierschenk/developer_setup/main/install.ps1 | iex
```

When it finishes, you'll see a message like `Done. The skill is installed at: ...` followed by the full path on your laptop.

---

## Step 3 — Confirm Claude Code can find it

A quick check that the file landed in the right place. Copy the single line for your OS, paste it at the same prompt, and press Enter.

**macOS or Linux:**
```
ls ~/.claude/skills/dev-bootstrap/SKILL.md
```

**Windows (PowerShell):**
```
ls $HOME\.claude\skills\dev-bootstrap\SKILL.md
```

If the path prints back, Claude Code will pick up the skill the next time it launches.

---

## Step 4 — Open Claude Code and ask it to install your tools

a. Start Claude Code by running `claude` in your terminal. 

b. Then type one of the requests below, and press Enter. **The wording you choose tells Claude which mode to run in** — pick the one that matches how hands-on you want to be.

| If you want...                                                | Type this into Claude Code                          |
| ------------------------------------------------------------- | --------------------------------------------------- |
| **Install everything missing, no questions asked**            | `install everything for my dev environment`         |
| **Walk me through each install one at a time, with confirmation** | `set up my dev environment step by step`        |
| **Upgrade everything I already have to the latest version**   | `update everything to latest`                       |
| Let Claude ask me which mode I want                           | `set up my dev environment`                         |

Claude will:
1. Detect your OS.
2. Check what's already installed and what's missing (one combined permission prompt for the whole survey, not one per tool).
3. Run installs in the mode you picked. (It pauses to confirm before oh-my-zsh either way — that one changes your shell.)
4. Verify everything and print a status table at the end.

A few installs need *your help in a new terminal tab* 
 `gh auth login`.

---

## Step 5 — Authenticate with GitHub

Once tools are installed, Claude walks you through GitHub setup automatically. **Don't skip this** — it's the difference between `git push` working silently and `git push` triggering macOS Keychain pop-ups every time.

Claude will:

1. **Set your git identity** — ask for your name and the email you use on GitHub, then run `git config --global user.name "..."` and `git config --global user.email "..."` for you.
2. **Log you into the GitHub CLI** — run `gh auth login`, which opens your browser and asks you to paste a one-time code. Pick **HTTPS** when prompted, and answer **Yes** to "Authenticate Git with your GitHub credentials?"
3. **Make `gh` the git credential helper** — runs `gh auth setup-git` so git stops asking for a password (no more macOS Keychain pop-ups).
4. **Verify it works** — runs `gh auth status` and `gh repo list` to confirm. If repos print without a prompt, you're set.

The whole walkthrough takes about 60 seconds and Claude does the typing — you just answer the prompts.

---

## Step 6 — Finish any manual steps Claude flags

Some tools need one human action before they work. Claude will tell you which apply:

- **macOS:** Click through the Xcode Command Line Tools GUI prompt.
- **Windows:** Close and reopen PowerShell so the new tools are on PATH.
- **Linux:** Log out and back in (so any group changes take effect).

---

## Verifying your toolchain any time

Claude prints a colored status table at the end of the bootstrap, but you can also run it yourself whenever. Paste the line for your OS into your terminal:

**macOS or Linux:**
```
curl -fsSL https://raw.githubusercontent.com/allisonbierschenk/developer_setup/main/verify.sh | bash
```

**Windows (PowerShell):**
```
irm https://raw.githubusercontent.com/allisonbierschenk/developer_setup/main/verify.ps1 | iex
```

You'll get a ✓/✗ table showing which tools are installed and their versions — green for installed, red for missing.

---

## What gets installed

| Tool           | macOS                                    | Windows                              | Linux (apt / dnf)                   |
| -------------- | ---------------------------------------- | ------------------------------------ | ----------------------------------- |
| Xcode CLT      | `xcode-select --install`                 | —                                    | —                                   |
| Homebrew       | install.sh from brew.sh                  | —                                    | —                                   |
| Git            | `brew install git`                       | `winget Git.Git`                     | `git`                               |
| GitHub CLI     | `brew install gh`                        | `winget GitHub.cli`                  | `gh`                                |
| Node.js (LTS)  | `brew install node`                      | `winget OpenJS.NodeJS.LTS`           | NodeSource / `nodejs`               |
| Heroku CLI     | `brew install heroku/brew/heroku`        | `winget Heroku.HerokuCLI`            | `cli-assets.heroku.com/install.sh`  |
| Python         | `brew install python`                    | `winget Python.Python.3.12`          | `python3 python3-pip`               |
| VS Code        | `brew install --cask visual-studio-code` | `winget Microsoft.VisualStudioCode`  | snap / Microsoft repo               |
| oh-my-zsh      | ohmyzsh install.sh                       | (use WSL2 + Linux flow)              | `zsh` + ohmyzsh install.sh          |
| Salesforce CLI | `npm i -g @salesforce/cli`               | `npm i -g @salesforce/cli`           | `npm i -g @salesforce/cli`          |
| Slack CLI      | `slack-cli/install.sh`                   | `slack-cli/install-windows.ps1`      | `slack-cli/install.sh`              |
| GitHub auth    | `gh auth login` + `gh auth setup-git`    | same                                 | same                                |

---

## Already have some tools installed?

| You have...                  | What the skill does                                                                       |
| ---------------------------- | ----------------------------------------------------------------------------------------- |
| Some tools, missing others   | Installs only what's missing.                                                             |
| An older version of a tool   | Skips it. Tells you the version it found.                                                 |
| You want it upgraded         | Ask: "upgrade node" or "update everything to latest". Claude uses the right upgrade command. |
| Nothing installed            | Installs everything in dependency order (Node before Salesforce CLI). |

---

## Updating the skill on your laptop

**Updates do not push to anyone automatically.** Each developer has their own copy of `SKILL.md` saved locally on their laptop. When someone (you or another contributor) edits the skill in this repo and pushes to `main`, that change only updates the version on GitHub — it does **not** reach into anyone else's `~/.claude/skills/` folder.

To pull the latest version onto your laptop, re-run the Step 2 command:

**macOS or Linux:**
```
curl -fsSL https://raw.githubusercontent.com/allisonbierschenk/developer_setup/main/install.sh | bash
```

**Windows (PowerShell):**
```
irm https://raw.githubusercontent.com/allisonbierschenk/developer_setup/main/install.ps1 | iex
```

It overwrites your local `SKILL.md` with the latest version from `main`. Do this any time someone announces a skill update in Slack, or whenever you want the newest tool list.

### How to let teammates know about updates

If you push a meaningful change to the skill (new tool, fixed install command, etc.), drop a note in the team Slack channel telling everyone to re-run the Step 2 command. They won't get the update otherwise.

---

## Repo layout

```
developer_setup/
├── README.md
├── install.sh                       # mac/linux bootstrap (curl | bash)
├── install.ps1                      # windows bootstrap (irm | iex)
├── verify.sh                        # mac/linux toolchain check (colored table)
├── verify.ps1                       # windows toolchain check (colored table)
└── skills/
    └── dev-bootstrap/
        └── SKILL.md                 # the skill Claude Code reads
```

---

## Contributing

Clone the repo, edit `skills/dev-bootstrap/SKILL.md`, update the table above, commit, push. Other devs re-run the Step 2 command to pull your changes.
