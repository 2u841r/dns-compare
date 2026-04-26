#!/bin/bash

primary_servers=("8.8.8.8" "1.1.1.1" "208.67.222.222" "9.9.9.9" "45.90.28.0" "94.140.14.14" "185.222.222.222" "194.242.2.2" "77.88.8.8" "40.120.32.158" "193.110.81.0" "119.29.29.29" "76.76.2.2")
primary_names=("Google" "Cloudflare" "OpenDNS" "Quad9" "NextDNS" "AdGuard" "DNS SB" "Mullvad" "Yandex" "KahfGuard" "Dns0.eu" "Tencent" "Control D")

secondary_servers=("8.8.4.4" "1.0.0.1" "208.67.220.220" "149.112.112.112" "45.90.30.0" "94.140.15.15" "45.11.45.11" "194.242.2.4" "77.88.8.1" "40.120.32.159" "185.253.5.0" "119.28.28.28" "76.76.10.2")
secondary_names=("Google 2" "Cloudflare 2" "OpenDNS 2" "Quad9 2" "NextDNS 2" "AdGuard 2" "DNS SB 2" "Mullvad 2" "Yandex 2" "KahfGuard 2" "Dns0.eu 2" "Tencent 2" "Control D 2")

test_dns_servers() {
    local -n servers_ref=$1
    local -n names_ref=$2
    local category=$3
    local -n results_ref=$4
    
    echo "Testing $category DNS servers..."
    echo
    
    for i in "${!servers_ref[@]}"; do
        echo -n "Testing ${names_ref[$i]}... "
        
        start_time=$(date +%s%3N)
        result=$(dig @${servers_ref[$i]} google.com +short +time=3 +tries=1 2>/dev/null)
        end_time=$(date +%s%3N)
        
        response_time=$((end_time - start_time))
        
        if [ -n "$result" ]; then
            status="✓ OK"
            echo "${response_time}ms"
            results_ref+=("${response_time}|${names_ref[$i]}|${servers_ref[$i]}|${status}")
        else
            status="✗ FAIL"
            echo "FAILED"
            results_ref+=("9999|${names_ref[$i]}|${servers_ref[$i]}|${status}")
        fi
    done
}

show_results_table() {
    local -n results_ref=$1
    local title=$2
    
    echo
    echo "$title (sorted by speed - fastest to slowest):"
    echo
    
    IFS=$'\n' sorted=($(sort -t'|' -n <<<"${results_ref[*]}"))
    
    printf "%-4s %-12s %-15s %-10s %-10s\n" "Rank" "DNS Provider" "Server" "Status" "Time (ms)"
    printf "%-4s %-12s %-15s %-10s %-10s\n" "----" "------------" "---------------" "----------" "----------"
    
    rank=1
    for result in "${sorted[@]}"; do
        IFS='|' read -r time name server status <<< "$result"
        
        if [ "$time" = "9999" ]; then
            time_display="N/A"
        else
            time_display="${time}ms"
        fi
        
        printf "%-4s %-12s %-15s %-10s %-10s\n" "$rank" "$name" "$server" "$status" "$time_display"
        ((rank++))
    done
}

primary_results=()
secondary_results=()

test_dns_servers primary_servers primary_names "Primary" primary_results
test_dns_servers secondary_servers secondary_names "Secondary" secondary_results

show_results_table primary_results "PRIMARY DNS SERVERS RESULTS"
show_results_table secondary_results "SECONDARY DNS SERVERS RESULTS"

echo
echo "Testing completed!"
