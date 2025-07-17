Table of Contents
- [Windows](#windows)
- [Ubuntu](#ubuntu)


## Windows 
[Download](https://github.com/2u841r/dns-compare/raw/refs/heads/main/dns/DNSSpeedTest.exe) file 
ignore anti-virus warning- its safe. and click on "Run Anyway"
![how to use](./how-to.gif)

or 
Paste this code in Powershell
```bash
# DNS Speed Test Script
# Define DNS servers and their names
$servers = @(
    "8.8.8.8",           # Google
    "8.8.4.4",           # Google 2
    "1.1.1.1",           # Cloudflare
    "1.0.0.1",           # Cloudflare 2
    "208.67.222.222",    # OpenDNS
    "208.67.220.220",    # OpenDNS 2
    "9.9.9.9",           # Quad9
    "149.112.112.112",   # Quad9 2 
    "45.90.28.0",        # NextDNS
    "45.90.30.0",        # NextDNS 2
    "94.140.14.14",      # AdGuard
    "94.140.15.15",      # AdGuard 2
    "185.222.222.222",   # DNS.SB
    "45.11.45.11",       # DNS.SB 2
    "194.242.2.2",       # Mullvad
    "194.242.2.4",       # Mullvad
    "77.88.8.8",         # Yandex
    "77.88.8.1",         # Yandex 2
    "40.120.32.158",     # KahfGuard
    "40.120.32.159",     # KahfGuard 2
    "193.110.81.0",      # Dns0.eu
    "185.253.5.0",       # Dns0.eu 2
    "119.29.29.29"       # Tencent
    "119.28.28.28"       # Tencent 2
)

$names = @(
    "Google",
    "Google 2",
    "Cloudflare", 
    "Cloudflare 2", 
    "OpenDNS",
    "OpenDNS 2",
    "Quad9",
    "Quad9 2",
    "NextDNS",
    "NextDNS 2",
    "AdGuard",
    "AdGuard 2",
    "DNS SB",
    "DNS SB 2",
    "Mullvad",
    "Mullvad 2",
    "Yandex",
    "Yandex 2",
    "KahfGuard",
    "KahfGuard 2",
    "Dns0.eu",
    "Dns0.eu 2",
    "Tencent"
    "Tencent 2"
)

# Initialize results array
$results = @()

Write-Host "Testing DNS servers..." -ForegroundColor Yellow
Write-Host

# Test each DNS server
for ($i = 0; $i -lt $servers.Length; $i++) {
    Write-Host "Testing $($names[$i])... " -NoNewline -ForegroundColor Cyan
    
    try {
        # Measure response time
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        
        # Perform DNS query using Resolve-DnsName
        $result = Resolve-DnsName -Name "google.com" -Server $servers[$i] -Type A -ErrorAction Stop -DnsOnly
        
        $stopwatch.Stop()
        $responseTime = $stopwatch.ElapsedMilliseconds
        
        # Check if we got a valid result
        if ($result -and $result.IPAddress) {
            $status = "✓ OK"
            Write-Host "${responseTime}ms" -ForegroundColor Green
            
            # Store result
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
        $status = "✗ FAIL"
        Write-Host "FAILED" -ForegroundColor Red
        
        # Store failed result with high number for sorting
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

# Sort results by response time
$sortedResults = $results | Sort-Object ResponseTime

# Print table header
Write-Host ("{0,-4} {1,-12} {2,-15} {3,-10} {4,-10}" -f "Rank", "DNS Provider", "Server", "Status", "Time (ms)") -ForegroundColor White
Write-Host ("{0,-4} {1,-12} {2,-15} {3,-10} {4,-10}" -f "----", "------------", "---------------", "----------", "----------") -ForegroundColor Gray

# Print sorted results with ranking
$rank = 1
foreach ($result in $sortedResults) {
    # Format time display
    if ($result.ResponseTime -eq 9999) {
        $timeDisplay = "N/A"
        $color = "Red"
    } else {
        $timeDisplay = $result.ResponseTime.ToString() + "ms"
        $color = "Green"
    }
    
    $statusColor = if ($result.Status -eq "✓ OK") { "Green" } else { "Red" }
    
    Write-Host ("{0,-4} {1,-12} {2,-15} " -f $rank, $result.Name, $result.Server) -NoNewline
    Write-Host ("{0,-10} " -f $result.Status) -NoNewline -ForegroundColor $statusColor
    Write-Host ("{0,-10}" -f $timeDisplay) -ForegroundColor $color
    
    $rank++
}

```


![Repo Views](https://repostats.deno.dev/2u841r/dns-compare)


## Ubuntu
In Ubuntu or WSL, Install bind9-dnsutils
```bash
sudo apt install bind9-dnsutils
```

then run
```bash
#!/bin/bash

servers=("8.8.8.8" "1.1.1.1" "208.67.222.222" "9.9.9.9" "45.90.28.0" "94.140.14.14" "185.222.222.222" "194.242.2.2" "77.88.8.8" "40.120.32.170" "193.110.81.0" "119.29.29.29")
names=("Google" "Cloudflare" "OpenDNS" "Quad9" "NextDNS" "AdGuard" "DNS SB" "Mullvad" "Yandex" "KahfGuard" "Dns0.eu" "Tencent")

# Arrays to store results
results=()

echo "Testing DNS servers..."
echo

for i in "${!servers[@]}"; do
    echo -n "Testing ${names[$i]}... "
    
    # Capture the time and result
    start_time=$(date +%s%3N)
    result=$(dig @${servers[$i]} google.com +short +time=3 +tries=1 2>/dev/null)
    end_time=$(date +%s%3N)
    
    # Calculate response time
    response_time=$((end_time - start_time))
    
    # Check if query was successful
    if [ -n "$result" ]; then
        status="✓ OK"
        echo "${response_time}ms"
        # Store: "response_time|name|server|status"
        results+=("${response_time}|${names[$i]}|${servers[$i]}|${status}")
    else
        status="✗ FAIL"
        echo "FAILED"
        # Store failed results with high number for sorting
        results+=("9999|${names[$i]}|${servers[$i]}|${status}")
    fi
done

echo
echo "Results sorted by speed (fastest to slowest):"
echo

# Sort results by response time (first field)
IFS=$'\n' sorted=($(sort -t'|' -n <<<"${results[*]}"))

# Print table header
printf "%-4s %-12s %-15s %-10s %-10s\n" "Rank" "DNS Provider" "Server" "Status" "Time (ms)"
printf "%-4s %-12s %-15s %-10s %-10s\n" "----" "------------" "---------------" "----------" "----------"

# Print sorted results with ranking
rank=1
for result in "${sorted[@]}"; do
    IFS='|' read -r time name server status <<< "$result"
    
    # Format time display
    if [ "$time" = "9999" ]; then
        time_display="N/A"
    else
        time_display="${time}"
    fi
    
    printf "%-4s %-12s %-15s %-10s %-10s\n" "$rank" "$name" "$server" "$status" "$time_display"
    ((rank++))
done

```

