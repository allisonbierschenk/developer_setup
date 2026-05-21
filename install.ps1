# dev-bootstrap skill installer (Windows PowerShell)
# Usage: irm https://raw.githubusercontent.com/allisonbierschenk/developer_setup/main/install.ps1 | iex

$ErrorActionPreference = 'Stop'

$RepoRaw   = 'https://raw.githubusercontent.com/allisonbierschenk/developer_setup/main'
$SkillName = 'dev-bootstrap'
$Dest      = Join-Path $HOME ".claude\skills\$SkillName"

Write-Host ""
Write-Host "▸ Installing the $SkillName Claude skill" -ForegroundColor Cyan
Write-Host "  destination: $Dest" -ForegroundColor DarkGray
Write-Host ""

New-Item -ItemType Directory -Path $Dest -Force | Out-Null

Write-Host "  ↓ Downloading SKILL.md... " -NoNewline -ForegroundColor Yellow
try {
    Invoke-WebRequest `
        -Uri "$RepoRaw/skills/$SkillName/SKILL.md" `
        -OutFile (Join-Path $Dest 'SKILL.md')
    Write-Host "done" -ForegroundColor Green
} catch {
    Write-Host "failed" -ForegroundColor Red
    throw
}

Write-Host ""
Write-Host "✓ Skill installed" -ForegroundColor Green
Write-Host "  $Dest\SKILL.md" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Next: " -NoNewline
Write-Host "run Step 3 in the README to confirm Claude Code can find the skill."
Write-Host ""
