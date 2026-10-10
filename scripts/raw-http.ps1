# Talks to demo05 over HTTP with plain curl, no client in between. Prints each
# curl command, then the JSON-RPC result, formatted. -Raw shows the real
# response instead: one SSE frame with the result on its `data:` line. Starts demo05 if nothing is listening, and stops it after.
#
#   scripts/raw-http.ps1                        # call get_current_time for Asia/Tokyo
#   scripts/raw-http.ps1 -Method tools          # the tool list, exactly what the model reads
#   scripts/raw-http.ps1 -TimeZone Tokyo        # the error message
#   scripts/raw-http.ps1 -Method read           # resources/read time://zones
#   scripts/raw-http.ps1 -Method all            # every request, one after another
#   scripts/raw-http.ps1 -Raw                   # the SSE frame, exactly as it arrived

param(
    [ValidateSet('call', 'tools', 'resources', 'read', 'prompts', 'prompt', 'all')]
    [string]$Method = 'call',
    [string]$TimeZone = 'Asia/Tokyo',
    [string]$Url = 'http://localhost:6233/',
    # Prints the response exactly as it came over the wire, instead of formatted.
    [switch]$Raw
)

$repo = Split-Path $PSScriptRoot -Parent

# Formats JSON without reading it into PowerShell objects. ConvertFrom-Json turns
# date strings into DateTime and shifts them to this machine's clock.
function Format-Json([string]$json) {
    $options = [System.Text.Json.JsonSerializerOptions]::new()
    $options.WriteIndented = $true
    $options.Encoder = [System.Text.Encodings.Web.JavaScriptEncoder]::UnsafeRelaxedJsonEscaping
    [System.Text.Json.Nodes.JsonNode]::Parse($json).ToJsonString($options)
}

$requests = [ordered]@{
    tools     = '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
    call      = '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"get_current_time","arguments":{"timeZone":"' + $TimeZone + '"}}}'
    resources = '{"jsonrpc":"2.0","id":3,"method":"resources/list"}'
    read      = '{"jsonrpc":"2.0","id":4,"method":"resources/read","params":{"uri":"time://zones"}}'
    prompts   = '{"jsonrpc":"2.0","id":5,"method":"prompts/list"}'
    prompt    = '{"jsonrpc":"2.0","id":6,"method":"prompts/get","params":{"name":"find_meeting_time","arguments":{"timeZones":"America/New_York, Europe/London, Asia/Tokyo"}}}'
}
$selected = if ($Method -eq 'all') { @($requests.Keys) } else { @($Method) }

function Test-Server {
    curl.exe -s -o NUL -m 1 $Url
    $LASTEXITCODE -eq 0
}

$started = $null
if (-not (Test-Server)) {
    Write-Host "Nothing on $Url, so starting demo05..." -ForegroundColor DarkGray
    $started = Start-Process dotnet -ArgumentList 'run', '--no-build', '--project', "`"$repo\src\demo05`"" -WindowStyle Hidden -PassThru
    foreach ($i in 1..30) {
        if (Test-Server) { break }
        Start-Sleep -Milliseconds 500
    }
}

try {
    foreach ($name in $selected) {
        $body = $requests[$name]
        Write-Host "> curl $Url -H `"Accept: application/json, text/event-stream`" -H `"Content-Type: application/json`" -d '$body'" -ForegroundColor Cyan

        # The body goes in on stdin so PowerShell can't mangle its quotes.
        $response = $body | curl.exe -s -m 15 $Url `
            -H 'Accept: application/json, text/event-stream' `
            -H 'Content-Type: application/json' `
            -H 'MCP-Protocol-Version: 2025-11-25' `
            --data-binary '@-'

        if (-not $Raw) {
            $data = ($response | Where-Object { $_ -like 'data:*' } | Select-Object -First 1)
            if ($data) {
                $response = Format-Json $data.Substring(5)
            }
        }
        Write-Host ($response -join "`n") -ForegroundColor Yellow
        Write-Host ''
    }
}
finally {
    if ($started) {
        Get-Process TimeServer -ErrorAction SilentlyContinue |
            Where-Object { $_.Path -like "$repo\src\demo05\*" } |
            Stop-Process -Force
        Stop-Process -Id $started.Id -Force -ErrorAction SilentlyContinue
    }
}
