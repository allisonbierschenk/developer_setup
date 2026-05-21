#!/usr/bin/env bash
# dev-bootstrap toolchain verifier (macOS / Linux)
# Usage: curl -fsSL https://raw.githubusercontent.com/allisonbierschenk/developer_setup/main/verify.sh | bash

G=$'\033[32m'; R=$'\033[31m'; C=$'\033[36m'; D=$'\033[2m'; B=$'\033[1m'; X=$'\033[0m'

row() {
  local name=$1 ver=$2
  if [ -n "$ver" ]; then
    printf "  ${G}✓${X} ${B}%-12s${X} ${C}%s${X}\n" "$name" "$ver"
  else
    printf "  ${R}✗${X} ${B}%-12s${X} ${D}not found${X}\n" "$name"
  fi
}

printf "\n${B}Toolchain status${X}\n${D}─────────────────────────────────────────────${X}\n"
row git       "$(git --version 2>/dev/null | awk '{print $3}')"
row node      "$(node -v 2>/dev/null)"
row npm       "$(npm -v 2>/dev/null)"
row gh        "$(gh --version 2>/dev/null | head -1 | awk '{print $3}')"
row heroku    "$(heroku --version 2>/dev/null | awk '{print $1}')"
row python3   "$(python3 --version 2>/dev/null | awk '{print $2}')"
row code      "$(code --version 2>/dev/null | head -1)"
row sf        "$(sf --version 2>/dev/null | awk '{print $1}')"
row slack     "$(slack version 2>/dev/null | awk '{print $NF}')"
row tabcmd    "$(tabcmd --version 2>/dev/null | grep -i 'tableau\|version' | tail -1 | awk '{print $NF}')"
row brew      "$(brew --version 2>/dev/null | head -1 | awk '{print $2}')"
row oh-my-zsh "$([ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ] && echo installed)"
printf "${D}─────────────────────────────────────────────${X}\n\n"
