# Talks to a demo server over stdio with no client in between: writes JSON-RPC
# lines to its stdin and prints what comes back on stdout. Logs (stderr) are
# discarded, the same way a client ignores them.
#
#   scripts/raw-stdio.ps1                        # demo04: call get_current_time for Asia/Tokyo
#   scripts/raw-stdio.ps1 -Method tools -Pretty  # the tool list, exactly what the model reads
#   scripts/raw-stdio.ps1 -Method resources      # or prompts
#   scripts/raw-stdio.ps1 -Demo demo03           # shows the stdout bug, raw
#   scripts/raw-stdio.ps1 -TimeZone Tokyo        # shows the error message

param(
    [string]$Demo = 'demo04',
    [ValidateSet('call', 'tools', 'resources', 'prompts')]
    [string]$Method = 'call',
    [string]$TimeZone = 'Asia/Tokyo',
    # Indents each response. Off by default, because one message per line is the real wire format.
    [switch]$Pretty
)

$request = switch ($Method) {
    'call' { '{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"get_current_time","arguments":{"timeZone":"' + $TimeZone + '"}}}' }
    default { '{"jsonrpc":"2.0","id":2,"method":"' + $Method + '/list"}' }
}

$repo = Split-Path $PSScriptRoot -Parent

$messages = @(
    '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"raw-stdio","version":"1.0"}}}'
    '{"jsonrpc":"2.0","method":"notifications/initialized"}'
    $request
)

$psi = [System.Diagnostics.ProcessStartInfo]::new(
    'cmd.exe', "/c dotnet run --no-build --project `"$repo\src\$Demo`" 2>NUL")
$psi.UseShellExecute = $false
$psi.RedirectStandardInput = $true
$psi.RedirectStandardOutput = $true
$server = [System.Diagnostics.Process]::Start($psi)

try {
    foreach ($message in $messages) {
        Write-Host "stdin  > $message" -ForegroundColor Cyan
        $server.StandardInput.WriteLine($message)

        # Notifications have no id and get no reply.
        if ($message -notmatch '"id":') { continue }

        $read = $server.StandardOutput.ReadLineAsync()
        if ($read.Wait(15000)) {
            $response = $read.Result
            if ($Pretty) {
                # A line that isn't pure JSON (the demo03 bug) prints as is.
                try { $response = "`n" + ($response | ConvertFrom-Json -Depth 64 | ConvertTo-Json -Depth 64) } catch { }
            }
            Write-Host "stdout < $response" -ForegroundColor Yellow
        }
        else {
            Write-Host 'stdout < (nothing after 15 seconds)' -ForegroundColor Red
        }
        Write-Host ''
    }
}
finally {
    $server.StandardInput.Close()
    Get-Process TimeServer -ErrorAction SilentlyContinue |
        Where-Object { $_.Path -like "$repo\src\$Demo\*" } |
        Stop-Process -Force
}
