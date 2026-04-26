$primaryServers = @(
    "8.8.8.8",
    "1.1.1.1",
    "208.67.222.222",
    "9.9.9.9",
    "45.90.28.0",
    "94.140.14.14",
    "185.222.222.222",
    "194.242.2.2",
    "77.88.8.8",
    "40.120.32.158",
    "193.110.81.0",
    "119.29.29.29",
    "76.76.2.2"
)

$primaryNames = @(
    "Google",
    "Cloudflare",
    "OpenDNS",
    "Quad9",
    "NextDNS",
    "AdGuard",
    "DNS SB",
    "Mullvad",
    "Yandex",
    "KahfGuard",
    "Dns0.eu",
    "Tencent",
    "Control D"
)

$secondaryServers = @(
    "8.8.4.4",
    "1.0.0.1",
    "208.67.220.220",
    "149.112.112.112",
    "45.90.30.0",
    "94.140.15.15",
    "45.11.45.11",
    "194.242.2.4",
    "77.88.8.1",
    "40.120.32.159",
    "185.253.5.0",
    "119.28.28.28",
    "76.76.10.2"
)

$secondaryNames = @(
    "Google 2",
    "Cloudflare 2",
    "OpenDNS 2",
    "Quad9 2",
    "NextDNS 2",
    "AdGuard 2",
    "DNS SB 2",
    "Mullvad 2",
    "Yandex 2",
    "KahfGuard 2",
    "Dns0.eu 2",
    "Tencent 2",
    "Control D 2"
)

function Test-DNSServers {
    param(
        [array]$servers,
        [array]$names,
        [string]$category
    )
    
    $results = @()
    
    Write-Host "Testing $category DNS servers..." -ForegroundColor Yellow
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
    
    return $results
}

function Show-ResultsTable {
    param(
        [array]$results,
        [string]$title
    )
    
    Write-Host
    Write-Host "$title (sorted by speed - fastest to slowest):" -ForegroundColor Yellow
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
}

$primaryResults = Test-DNSServers -servers $primaryServers -names $primaryNames -category "Primary"
$secondaryResults = Test-DNSServers -servers $secondaryServers -names $secondaryNames -category "Secondary"

Show-ResultsTable -results $primaryResults -title "PRIMARY DNS SERVERS RESULTS"
Show-ResultsTable -results $secondaryResults -title "SECONDARY DNS SERVERS RESULTS"

Write-Host
Write-Host "Testing completed!" -ForegroundColor Green
