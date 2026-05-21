*Set up your dev laptop with one command*

No more copy-pasting a dozen commands — Claude does it for you.

*What you'll end up with:* git, GitHub CLI, Node.js, Heroku CLI, Python, VS Code, oh-my-zsh, Salesforce CLI, Slack CLI, and Tableau CLI (tabcmd 2.0). Plus GitHub auth set up so `git push` doesn't pop up Keychain prompts.

*Works on:* macOS, Windows, Linux.

---

*Step 1 — Install Claude Code*
Follow the Claude Code install canvas (link in this channel). Come back here when you can launch it.

*Step 2 — Download the skill*
Open your terminal (Terminal on macOS/Linux, PowerShell on Windows). Paste *only* the line for your OS and press Enter. Don't type `bash` or `cd` first — just paste the line.

macOS or Linux:
```
curl -fsSL https://raw.githubusercontent.com/allisonbierschenk/developer_setup/main/install.sh | bash
```

Windows (PowerShell):
```
irm https://raw.githubusercontent.com/allisonbierschenk/developer_setup/main/install.ps1 | iex
```

You'll see a `Done. The skill is installed at: ...` message.

*Step 3 — Open Claude Code and ask it to install your tools*
Type one of these into Claude Code:

• `install everything for my dev environment` — installs everything missing, no per-tool confirmation
• `set up my dev environment step by step` — confirms before each install
• `update everything to latest` — upgrades tools you already have
• `set up my dev environment` — Claude asks which mode you want

Claude will detect your OS, check what you already have, install what's missing, walk you through GitHub auth (`gh auth login` + `gh auth setup-git`), and print a status table at the end.

A few installs need *your* terminal (sudo prompts, browser flows). When Claude hits one, it'll hand you a command starting with `!` — paste that into your Claude Code prompt and press Enter. Examples: Xcode Command Line Tools, Homebrew, oh-my-zsh, Slack CLI, `gh auth login`.

*Step 4 — Verify*
Claude prints a status table for you, but you can also run it yourself any time. Paste the line for your OS into your terminal — you'll get a colored ✓/✗ table of every tool and its version.

macOS or Linux:
```
curl -fsSL https://raw.githubusercontent.com/allisonbierschenk/developer_setup/main/verify.sh | bash
```

Windows (PowerShell):
```
irm https://raw.githubusercontent.com/allisonbierschenk/developer_setup/main/verify.ps1 | iex
```

---

*Skill Updates:* the skill on your laptop is a static copy — re-run the Step 2 command any time to pull in the latest version. No automatic updates.

