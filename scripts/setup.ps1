# Gets this machine ready to give the talk. Safe to run more than once.
# Undo everything with scripts/teardown.ps1.
#
# Leaves Claude Code with an empty .mcp.json, because both registrations
# happen live on stage with -s project: `time` (stdio, demo04) in step 6 and
# `time-http` (demo05) in step 7. On stage, Claude Code is launched with
# --strict-mcp-config --mcp-config .mcp.json, so no other MCP server can
# answer the Tokyo question. Codex and Copilot get the HTTP server ahead of
# time, as DEMO.md says.

$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$url = 'http://localhost:6233/'

Write-Host '== MCP server template'
dotnet new install Microsoft.McpServer.ProjectTemplates | Out-Null

Write-Host '== MCP Inspector (cache it so the stage needs no network)'
npm cache add '@modelcontextprotocol/inspector@2.9.0' | Out-Null

Write-Host '== Stop running demo servers (they lock their build output)'
Get-Process TimeServer -ErrorAction SilentlyContinue |
    Where-Object { $_.Path -like "$repo\src\*" } |
    Stop-Process -Force

Write-Host '== Build demo01-demo05'
foreach ($n in 1..5) {
    dotnet build (Join-Path $repo "src/demo0$n") -nologo -v q
    if ($LASTEXITCODE -ne 0) { throw "demo0$n failed to build" }
}

Write-Host '== Claude Code: clear leftover time servers'
foreach ($name in 'time', 'time-http') {
    foreach ($scope in 'local', 'user', 'project') {
        claude mcp remove $name -s $scope *> $null
    }
}
'{ "mcpServers": {} }' | Set-Content (Join-Path $repo '.mcp.json') -Encoding utf8NoBOM

Write-Host "== Codex: time -> $url"
codex mcp remove time *> $null
codex mcp add time --url $url
if ($LASTEXITCODE -ne 0) { throw 'codex mcp add failed' }

Write-Host "== Copilot: .vscode/mcp.json -> $url"
$vscode = Join-Path $repo '.vscode'
New-Item -ItemType Directory -Force $vscode | Out-Null
@"
{
  "servers": {
    "time": { "type": "http", "url": "$url" }
  }
}
"@ | Set-Content (Join-Path $vscode 'mcp.json') -Encoding utf8NoBOM

Write-Host ''
Write-Host 'Done. Still by hand:'
Write-Host '  - Start the HTTP server before step 7: Solo "MCP server (HTTP)", or dotnet run --project src/demo05'
Write-Host '  - In the Inspector settings, set Request Timeout to about 10 seconds'
Write-Host '  - Open the repo in VS Code and start the "time" server from .vscode/mcp.json'
