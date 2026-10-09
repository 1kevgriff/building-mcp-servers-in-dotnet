# Undoes scripts/setup.ps1 and anything registered live on stage.
# Leaves the template, the npm cache and the build output alone.

$repo = Split-Path $PSScriptRoot -Parent

Write-Host '== Stop the HTTP server on port 6233'
Get-NetTCPConnection -LocalPort 6233 -State Listen -ErrorAction SilentlyContinue |
    ForEach-Object { Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue }

Write-Host '== Claude Code: remove time and time-http'
foreach ($name in 'time', 'time-http') {
    foreach ($scope in 'local', 'user', 'project') {
        claude mcp remove $name -s $scope *> $null
    }
}
Remove-Item (Join-Path $repo '.mcp.json') -ErrorAction SilentlyContinue

Write-Host '== Codex: remove time'
codex mcp remove time *> $null

Write-Host '== Copilot: remove .vscode/mcp.json'
$vscode = Join-Path $repo '.vscode'
Remove-Item (Join-Path $vscode 'mcp.json') -ErrorAction SilentlyContinue
if ((Test-Path $vscode) -and -not (Get-ChildItem $vscode -Force)) { Remove-Item $vscode }

Write-Host 'Done.'
