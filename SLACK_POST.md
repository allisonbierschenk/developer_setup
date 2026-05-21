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
Claude prints a status table for you, but you can also run it yourself any time. Paste the *whole block* for your OS (all of it, in one paste) into your terminal — you'll get a colored ✓/✗ table of every tool and its version.

macOS or Linux:
```
G=$'\033[32m';R=$'\033[31m';C=$'\033[36m';D=$'\033[2m';B=$'\033[1m';X=$'\033[0m';r(){ if [ -n "$2" ]; then printf "  ${G}✓${X} ${B}%-12s${X} ${C}%s${X}\n" "$1" "$2"; else printf "  ${R}✗${X} ${B}%-12s${X} ${D}not found${X}\n" "$1"; fi; };printf "\n${B}Toolchain status${X}\n${D}─────────────────────────────────────────────${X}\n";r git "$(git --version 2>/dev/null|awk '{print $3}')";r node "$(node -v 2>/dev/null)";r npm "$(npm -v 2>/dev/null)";r gh "$(gh --version 2>/dev/null|head -1|awk '{print $3}')";r heroku "$(heroku --version 2>/dev/null|awk '{print $1}')";r python3 "$(python3 --version 2>/dev/null|awk '{print $2}')";r code "$(code --version 2>/dev/null|head -1)";r sf "$(sf --version 2>/dev/null|awk '{print $1}')";r slack "$(slack version 2>/dev/null|awk '{print $NF}')";r tabcmd "$(tabcmd --version 2>/dev/null|grep -i 'tableau\|version'|tail -1|awk '{print $NF}')";r brew "$(brew --version 2>/dev/null|head -1|awk '{print $2}')";r oh-my-zsh "$([ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ] && echo installed)";printf "${D}─────────────────────────────────────────────${X}\n\n"
```

Windows (PowerShell):
```
function R($n,$v){if($v){Write-Host "  " -NoNewline;Write-Host "✓ " -ForegroundColor Green -NoNewline;Write-Host ("{0,-12}" -f $n) -NoNewline;Write-Host $v -ForegroundColor Cyan}else{Write-Host "  " -NoNewline;Write-Host "✗ " -ForegroundColor Red -NoNewline;Write-Host ("{0,-12}" -f $n) -NoNewline;Write-Host "not found" -ForegroundColor DarkGray}};function V($c,$a){try{(& $c @a 2>$null)-split "`n"|Select-Object -First 1}catch{$null}};Write-Host "";Write-Host "Toolchain status";Write-Host "─────────────────────────────────────────────" -ForegroundColor DarkGray;R "git" (V git --version);R "node" (V node -v);R "npm" (V npm -v);R "gh" (V gh --version);R "heroku" (V heroku --version);R "python" (V python --version);R "code" (V code --version);R "sf" (V sf --version);R "slack" (V slack version);R "tabcmd" (V tabcmd --version);Write-Host "─────────────────────────────────────────────" -ForegroundColor DarkGray;Write-Host ""
```

---

*Skill Updates:* the skill on your laptop is a static copy — re-run the Step 2 command any time to pull in the latest version. No automatic updates.

