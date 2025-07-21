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
# Define primary DNS servers and their names
$primaryServers = @(
    "8.8.8.8",           # Google
    "1.1.1.1",           # Cloudflare
    "208.67.222.222",    # OpenDNS
    "9.9.9.9",           # Quad9
    "45.90.28.0",        # NextDNS
    "94.140.14.14",      # AdGuard
    "185.222.222.222",   # DNS.SB
    "194.242.2.2",       # Mullvad
    "77.88.8.8",         # Yandex
    "40.120.32.158",     # KahfGuard
    "193.110.81.0",      # Dns0.eu
    "119.29.29.29"       # Tencent
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
    "Tencent"
)

# Define secondary DNS servers and their names
$secondaryServers = @(
    "8.8.4.4",           # Google 2
    "1.0.0.1",           # Cloudflare 2
    "208.67.220.220",    # OpenDNS 2
    "149.112.112.112",   # Quad9 2 
    "45.90.30.0",        # NextDNS 2
    "94.140.15.15",      # AdGuard 2
    "45.11.45.11",       # DNS.SB 2
    "194.242.2.4",       # Mullvad 2
    "77.88.8.1",         # Yandex 2
    "40.120.32.159",     # KahfGuard 2
    "185.253.5.0",       # Dns0.eu 2
    "119.28.28.28"       # Tencent 2
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
    "Tencent 2"
)

# Function to test DNS servers
function Test-DNSServers {
    param(
        [array]$servers,
        [array]$names,
        [string]$category
    )
    
    $results = @()
    
    Write-Host "Testing $category DNS servers..." -ForegroundColor Yellow
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
    
    return $results
}

# Function to display results table
function Show-ResultsTable {
    param(
        [array]$results,
        [string]$title
    )
    
    Write-Host
    Write-Host "$title (sorted by speed - fastest to slowest):" -ForegroundColor Yellow
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
}

# Test primary DNS servers
$primaryResults = Test-DNSServers -servers $primaryServers -names $primaryNames -category "Primary"

# Test secondary DNS servers  
$secondaryResults = Test-DNSServers -servers $secondaryServers -names $secondaryNames -category "Secondary"

# Display results in separate tables
Show-ResultsTable -results $primaryResults -title "PRIMARY DNS SERVERS RESULTS"
Show-ResultsTable -results $secondaryResults -title "SECONDARY DNS SERVERS RESULTS"

Write-Host
Write-Host "Testing completed!" -ForegroundColor Green

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

# Primary DNS servers
primary_servers=("8.8.8.8" "1.1.1.1" "208.67.222.222" "9.9.9.9" "45.90.28.0" "94.140.14.14" "185.222.222.222" "194.242.2.2" "77.88.8.8" "40.120.32.158" "193.110.81.0" "119.29.29.29")
primary_names=("Google" "Cloudflare" "OpenDNS" "Quad9" "NextDNS" "AdGuard" "DNS SB" "Mullvad" "Yandex" "KahfGuard" "Dns0.eu" "Tencent")

# Secondary DNS servers
secondary_servers=("8.8.4.4" "1.0.0.1" "208.67.220.220" "149.112.112.112" "45.90.30.0" "94.140.15.15" "45.11.45.11" "194.242.2.4" "77.88.8.1" "40.120.32.159" "185.253.5.0" "119.28.28.28")
secondary_names=("Google 2" "Cloudflare 2" "OpenDNS 2" "Quad9 2" "NextDNS 2" "AdGuard 2" "DNS SB 2" "Mullvad 2" "Yandex 2" "KahfGuard 2" "Dns0.eu 2" "Tencent 2")

# Function to test DNS servers
test_dns_servers() {
    local -n servers_ref=$1
    local -n names_ref=$2
    local category=$3
    local -n results_ref=$4
    
    echo "Testing $category DNS servers..."
    echo
    
    for i in "${!servers_ref[@]}"; do
        echo -n "Testing ${names_ref[$i]}... "
        
        # Capture the time and result
        start_time=$(date +%s%3N)
        result=$(dig @${servers_ref[$i]} google.com +short +time=3 +tries=1 2>/dev/null)
        end_time=$(date +%s%3N)
        
        # Calculate response time
        response_time=$((end_time - start_time))
        
        # Check if query was successful
        if [ -n "$result" ]; then
            status="✓ OK"
            echo "${response_time}ms"
            # Store: "response_time|name|server|status"
            results_ref+=("${response_time}|${names_ref[$i]}|${servers_ref[$i]}|${status}")
        else
            status="✗ FAIL"
            echo "FAILED"
            # Store failed results with high number for sorting
            results_ref+=("9999|${names_ref[$i]}|${servers_ref[$i]}|${status}")
        fi
    done
}

# Function to display results table
show_results_table() {
    local -n results_ref=$1
    local title=$2
    
    echo
    echo "$title (sorted by speed - fastest to slowest):"
    echo
    
    # Sort results by response time (first field)
    IFS=$'\n' sorted=($(sort -t'|' -n <<<"${results_ref[*]}"))
    
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
            time_display="${time}ms"
        fi
        
        printf "%-4s %-12s %-15s %-10s %-10s\n" "$rank" "$name" "$server" "$status" "$time_display"
        ((rank++))
    done
}

# Arrays to store results
primary_results=()
secondary_results=()

# Test primary DNS servers
test_dns_servers primary_servers primary_names "Primary" primary_results

# Test secondary DNS servers
test_dns_servers secondary_servers secondary_names "Secondary" secondary_results

# Display results in separate tables
show_results_table primary_results "PRIMARY DNS SERVERS RESULTS"
show_results_table secondary_results "SECONDARY DNS SERVERS RESULTS"

echo
echo "Testing completed!"
```

