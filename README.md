In WSL / Ubuntu, install
```bash
sudo apt install bind9-dnsutils
```

then run
```bash
#!/bin/bash

servers=("8.8.8.8" "1.1.1.1" "208.67.222.222" "9.9.9.9" "45.90.28.0" "94.140.14.14" "185.222.222.222" "40.120.32.170")
names=("Google" "Cloudflare" "OpenDNS" "Quad9" "NextDNS" "AdGuard" "DNS SB" "KahfGuard")

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
