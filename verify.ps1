# dev-bootstrap toolchain verifier (Windows PowerShell)
# Usage: irm https://raw.githubusercontent.com/allisonbierschenk/developer_setup/main/verify.ps1 | iex

$ErrorActionPreference = 'SilentlyContinue'

function Row($name, $ver) {
    if ($ver) {
        Write-Host "  " -NoNewline
        Write-Host "OK  " -ForegroundColor Green -NoNewline
        Write-Host ("{0,-12}" -f $name) -NoNewline
        Write-Host $ver -ForegroundColor Cyan
    } else {
        Write-Host "  " -NoNewline
        Write-Host "X   " -ForegroundColor Red -NoNewline
        Write-Host ("{0,-12}" -f $name) -NoNewline
        Write-Host "not found" -ForegroundColor DarkGray
    }
}

function Get-Ver($cmd, $args) {
    try { (& $cmd @args 2>$null) -split "`n" | Select-Object -First 1 } catch { $null }
}

Write-Host ""
Write-Host "Toolchain status"
Write-Host "─────────────────────────────────────────────" -ForegroundColor DarkGray

Row "git"       (Get-Ver git --version)
Row "node"      (Get-Ver node -v)
Row "npm"       (Get-Ver npm -v)
Row "gh"        (Get-Ver gh --version)
Row "heroku"    (Get-Ver heroku --version)
Row "python"    (Get-Ver python --version)
Row "code"      (Get-Ver code --version)
Row "sf"        (Get-Ver sf --version)
Row "slack"     (Get-Ver slack version)

Write-Host "─────────────────────────────────────────────" -ForegroundColor DarkGray
Write-Host ""
