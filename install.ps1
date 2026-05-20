# dev-bootstrap skill installer (Windows PowerShell)
# Usage: irm https://raw.githubusercontent.com/allisonbierschenk/developer_setup/main/install.ps1 | iex

$ErrorActionPreference = 'Stop'

$RepoRaw   = 'https://raw.githubusercontent.com/allisonbierschenk/developer_setup/main'
$SkillName = 'dev-bootstrap'
$Dest      = Join-Path $HOME ".claude\skills\$SkillName"

Write-Host "Installing the $SkillName Claude skill into $Dest..."

New-Item -ItemType Directory -Path $Dest -Force | Out-Null

Invoke-WebRequest `
    -Uri "$RepoRaw/skills/$SkillName/SKILL.md" `
    -OutFile (Join-Path $Dest 'SKILL.md')

Write-Host ""
Write-Host "Done. The skill is installed at:"
Write-Host "  $Dest\SKILL.md"
Write-Host ""
Write-Host "Next step: open Claude Code and ask it to ""set up my dev environment""."
Write-Host "Claude will detect your OS and walk you through the install."
