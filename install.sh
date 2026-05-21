#!/usr/bin/env bash
# dev-bootstrap skill installer (macOS / Linux)
# Usage: curl -fsSL https://raw.githubusercontent.com/allisonbierschenk/developer_setup/main/install.sh | bash

set -euo pipefail

G=$'\033[32m'; R=$'\033[31m'; C=$'\033[36m'; Y=$'\033[33m'; D=$'\033[2m'; B=$'\033[1m'; X=$'\033[0m'

REPO_RAW="https://raw.githubusercontent.com/allisonbierschenk/developer_setup/main"
SKILL_NAME="dev-bootstrap"
DEST="${HOME}/.claude/skills/${SKILL_NAME}"

printf "\n${B}${C}▸ Installing the %s Claude skill${X}\n" "$SKILL_NAME"
printf "${D}  destination: %s${X}\n\n" "$DEST"

mkdir -p "${DEST}"

printf "  ${Y}↓${X} Downloading SKILL.md... "
if curl -fsSL "${REPO_RAW}/skills/${SKILL_NAME}/SKILL.md" -o "${DEST}/SKILL.md"; then
  printf "${G}done${X}\n"
else
  printf "${R}failed${X}\n"
  exit 1
fi

printf "\n${G}${B}✓ Skill installed${X}\n"
printf "${D}  %s/SKILL.md${X}\n\n" "$DEST"

printf "${B}Next:${X} run Step 3 in the README to confirm Claude Code can find the skill.\n\n"
