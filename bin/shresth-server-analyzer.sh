#!/bin/bash

features_available() {
    echo -e "\n${CYAN}===== SHRESTH SERVER ANALYZER =====${NC}\n"
    echo -e "${WHITE}0. OS version"
    echo -e "1. Total CPU usage"
    echo -e "2. Total memory usage"
    echo -e "3. Total disk usage"
    echo -e "4. Top n processes by CPU usage"
    echo -e "5. Top n processes by memory usage"
    echo -e "6. Uptime"
    echo -e "7. Load average"
    echo -e "8. Logged in users"
    echo -e "9. Failed login attempts"
    echo -e "${GREEN}c. Clear screen${NC}"
    echo -e "${RED}q. Quit${NC}\n"
}

os_version() {
    echo -e "\n${CYAN}== Gathering OS Information ==${NC}\n"
    cat /etc/os-release
    return 0
}

total_cpu() {
    echo -e "\n${CYAN}== Total CPU Usage ==${NC}\n"
    usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')

    echo -e "${WHITE}CPU Usage:${NC} ${usage}%"
    return 0
}

total_mem() {
    echo -e "\n${CYAN}== Total Memory Usage (Free vs Used) ==${NC}\n"
    # Get memory info using free
    mem_total=$(free -m | awk '/Mem:/ {print $2}')
    mem_used=$(free -m | awk '/Mem:/ {print $3}')
    mem_free=$(free -m | awk '/Mem:/ {print $4}')
    mem_percent=$(awk "BEGIN {printf \"%.1f\", (${mem_used}/${mem_total})*100}")
    
    echo -e "${WHITE}Total Memory:${NC} ${mem_total} MB"
    echo -e "${WHITE}Used Memory:${NC} ${mem_used} MB (${mem_percent}%)"
    echo -e "${WHITE}Free Memory:${NC} ${mem_free} MB"
    return 0
}

total_disk() {
    echo -e "\n${CYAN}== Total Disk Usage (Free vs Used) ==${NC}\n"
    # Get disk info using df (root filesystem)
    disk_total=$(df -m / | awk 'NR==2 {print $2}')
    disk_used=$(df -m / | awk 'NR==2 {print $3}')
    disk_free=$(df -m / | awk 'NR==2 {print $4}')
    disk_percent=$(df -m / | awk 'NR==2 {print $5}' | tr -d '%')
    
    echo -e "${WHITE}Total Disk Space:${NC} ${disk_total} MB"
    echo -e "${WHITE}Used Disk Space:${NC} ${disk_used} MB (${disk_percent}%)"
    echo -e "${WHITE}Free Disk Space:${NC} ${disk_free} MB"
    return 0
}
top_n_cpu() {
    echo -e "\n${YELLOW}How many processes do you want to display?${NC}"
    read -r n
    echo -e "\n${CYAN}== Top ${n} Processes by CPU Usage ==${NC}\n"
    ps -eo pid,comm,%cpu --sort=-%cpu | awk 'NR==1 {print "'${BLUE}'" $0 "'${NC}'"} NR>1 {print $0}' | head -n "$((n + 1))"
    return 0
}

top_n_mem() {
    echo -e "\n${YELLOW}How many processes do you want to display?${NC}"
    read -r n
    echo -e "\n${CYAN}== Top ${n} Processes by Memory Usage ==${NC}\n"
    ps -eo pid,comm,%mem --sort=-%mem | awk 'NR==1 {print "'${BLUE}'" $0 "'${NC}'"} NR>1 {print $0}' | head -n "$((n + 1))"
    return 0
}

now_uptime() {
    echo -e "\n${CYAN}== System Uptime ==${NC}"
    uptime -p
    return 0
}

load_avg() {
    echo -e "\n${CYAN}== System Load Average ==${NC}"
    cat /proc/loadavg
    return 0
}

logged_in_users() {
    echo -e "\n${CYAN}== Logged In Users ==${NC}"
    who
    return 0
}

failed_login() {
    echo -e "\n${CYAN}== Failed Login Attempts ==${NC}\n"
    sudo grep --color=always "Failed password" /var/log/auth.log
    return 0
}

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

while true; do
    features_available
    echo -e "${YELLOW}Enter your choice:${NC} "
    read -r var
    case "$var" in
        0) os_version ;;
        1) total_cpu ;;
        2) total_mem ;;
        3) total_disk ;;
        4) top_n_cpu ;;
        5) top_n_mem ;;
        6) now_uptime ;;
        7) load_avg ;;
        8) logged_in_users ;;
        9) failed_login ;;
        c|C) clear ;;
        q|Q)
            echo -e "${GREEN}Exiting...${NC}"
            break
            ;;
        *) echo -e "${RED}Invalid option! Please select a valid choice.${NC}" ;;
    esac
done
