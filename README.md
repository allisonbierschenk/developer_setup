# developer_setup

A Claude Code skill that installs everything a developer needs on a laptop — git, GitHub CLI, Node.js, Heroku CLI, Python, Docker Desktop, VS Code, oh-my-zsh, Salesforce CLI, Slack CLI, and Tableau CLI (tabcmd 2.0). 

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

Open Claude Code, type the request below, and press Enter:

> set up my dev environment

Claude will:
1. Detect your OS.
2. Check what's already installed and what's missing.
3. Ask: install everything missing in one pass, or one at a time with confirmation?
4. Install the missing tools. (It pauses to confirm before oh-my-zsh — that one changes your shell.)
5. Verify each tool installed correctly.

---

## Step 5 — Finish any manual steps Claude flags

Some tools need one human action before they work. Claude will tell you which apply:

- **macOS:** Click through the Xcode Command Line Tools GUI prompt. Open Docker Desktop once.
- **Windows:** Close and reopen PowerShell.
- **Linux:** Log out and back in (so docker group takes effect).

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
| Docker Desktop | `brew install --cask docker`             | `winget Docker.DockerDesktop`        | `get.docker.com` script             |
| VS Code        | `brew install --cask visual-studio-code` | `winget Microsoft.VisualStudioCode`  | snap / Microsoft repo               |
| oh-my-zsh      | ohmyzsh install.sh                       | (use WSL2 + Linux flow)              | `zsh` + ohmyzsh install.sh          |
| Salesforce CLI | `npm i -g @salesforce/cli`               | `npm i -g @salesforce/cli`           | `npm i -g @salesforce/cli`          |
| Slack CLI      | `slack-cli/install.sh`                   | `slack-cli/install-windows.ps1`      | `slack-cli/install.sh`              |
| tabcmd 2.0     | `pip3 install tabcmd`                    | `pip install tabcmd`                 | `pip3 install tabcmd`               |

---

## Already have some tools installed?

| You have...                  | What the skill does                                                                       |
| ---------------------------- | ----------------------------------------------------------------------------------------- |
| Some tools, missing others   | Installs only what's missing.                                                             |
| An older version of a tool   | Skips it. Tells you the version it found.                                                 |
| You want it upgraded         | Ask: "upgrade node" or "update everything to latest". Claude uses the right upgrade command. |
| Nothing installed            | Installs everything in dependency order (Node before Salesforce CLI, Python before tabcmd). |

---

## Updating the skill on your laptop

Re-run the Step 2 command. It overwrites your local `SKILL.md` with the latest version.

---

## Repo layout

```
developer_setup/
├── README.md
├── install.sh                       # mac/linux bootstrap (curl | bash)
├── install.ps1                      # windows bootstrap (irm | iex)
└── skills/
    └── dev-bootstrap/
        └── SKILL.md                 # the skill Claude Code reads
```

---

## Contributing

Clone the repo, edit `skills/dev-bootstrap/SKILL.md`, update the table above, commit, push. Other devs re-run the Step 2 command to pull your changes.
