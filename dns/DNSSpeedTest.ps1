# DNS Speed Test Script
$servers = @(
    "8.8.8.8",           # Google
    "1.1.1.1",           # Cloudflare
    "208.67.222.222",    # OpenDNS
    "45.90.28.0",        # NextDNS
    "94.140.14.14",      # AdGuard
    "185.222.222.222",   # DNS.SB
    "40.120.32.170"      # KahfGuard
    "9.9.9.9",           # Quad9
    "77.88.8.8",         # Yandex
    "194.242.2.2"        # Mullvad
)

$names = @(
    "Google",
    "Cloudflare", 
    "OpenDNS",
    "NextDNS",
    "AdGuard",
    "DNS SB",
    "KahfGuard"
    "Quad9",
    "Yandex",
    "Mullvad"
)

$results = @()

Write-Host "Testing DNS servers..." -ForegroundColor Yellow
Write-Host

for ($i = 0; $i -lt $servers.Length; $i++) {
    Write-Host "Testing $($names[$i])... " -NoNewline -ForegroundColor Cyan
    
    try {
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        $result = Resolve-DnsName -Name "google.com" -Server $servers[$i] -Type A -ErrorAction Stop -DnsOnly
        $stopwatch.Stop()
        $responseTime = $stopwatch.ElapsedMilliseconds
        
        if ($result -and $result.IPAddress) {
            $status = "OK"
            Write-Host "${responseTime}ms" -ForegroundColor Green
            
            $results += [PSCustomObject]@{
                ResponseTime = $responseTime
                Name = $names[$i]
                Server = $servers[$i]
                Status = $status
            }
        } else {
            throw "No valid response"
        }
    }
    catch {
        $status = "FAIL"
        Write-Host "FAILED" -ForegroundColor Red
        
        $results += [PSCustomObject]@{
            ResponseTime = 9999
            Name = $names[$i]
            Server = $servers[$i]
            Status = $status
        }
    }
}

Write-Host
Write-Host "Results sorted by speed (fastest to slowest):" -ForegroundColor Yellow
Write-Host

$sortedResults = $results | Sort-Object ResponseTime

Write-Host ("{0,-4} {1,-12} {2,-15} {3,-10} {4,-10}" -f "Rank", "DNS Provider", "Server", "Status", "Time (ms)") -ForegroundColor White
Write-Host ("{0,-4} {1,-12} {2,-15} {3,-10} {4,-10}" -f "----", "------------", "---------------", "----------", "----------") -ForegroundColor Gray

$rank = 1
foreach ($result in $sortedResults) {
    $timeDisplay = if ($result.ResponseTime -eq 9999) { "N/A" } else { "$($result.ResponseTime)ms" }
    $color = if ($result.ResponseTime -eq 9999) { "Red" } else { "Green" }
    $statusColor = if ($result.Status -eq "OK") { "Green" } else { "Red" }
    
    Write-Host ("{0,-4} {1,-12} {2,-15} " -f $rank, $result.Name, $result.Server) -NoNewline
    Write-Host ("{0,-10} " -f $result.Status) -NoNewline -ForegroundColor $statusColor
    Write-Host ("{0,-10}" -f $timeDisplay) -ForegroundColor $color
    
    $rank++
}

Read-Host -Prompt "Press Enter to exit"