#!/usr/bin/env bash
# dev-bootstrap skill installer (macOS / Linux)
# Usage: curl -fsSL https://raw.githubusercontent.com/allisonbierschenk/developer_setup/main/install.sh | bash

set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/allisonbierschenk/developer_setup/main"
SKILL_NAME="dev-bootstrap"
DEST="${HOME}/.claude/skills/${SKILL_NAME}"

echo "Installing the ${SKILL_NAME} Claude skill into ${DEST}..."

mkdir -p "${DEST}"

curl -fsSL "${REPO_RAW}/skills/${SKILL_NAME}/SKILL.md" -o "${DEST}/SKILL.md"

echo ""
echo "Done. The skill is installed at:"
echo "  ${DEST}/SKILL.md"
echo ""
echo "Next step: open Claude Code and ask it to \"set up my dev environment\"."
echo "Claude will detect your OS and walk you through the install."
