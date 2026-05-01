#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
NC='\033[0m'

spinner() {
    local pid=$1
    local spinstr='|/-\'
    while ps -p $pid > /dev/null 2>&1; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        spinstr=$temp${spinstr%"$temp"}
        sleep 0.1
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

run_task() {
    local cmd=$1
    local msg=$2
    local err=$3
    
    echo -ne "${PURPLE}[*] ${msg}${NC}"
    (eval "$cmd" > /dev/null 2>&1) &
    local pid=$!
    spinner $pid
    wait $pid
    if [ $? -ne 0 ]; then
        echo -e "\n${RED}[!] ${err}${NC}"
        exit 1
    fi
    echo -e " ${GREEN}[OK]${NC}"
}

echo -e "${PURPLE}"
cat << "EOF"
 888    d8P         d8888 888      8888888      8888888888  8888888888     888          888888b.            
 888   d8P         d88888 888        888        888         888            888          888  "88b           
 888  d8P         d88P888 888        888        888         888            888          888  .88P           
 888d88K         d88P 888 888        888        8888888     8888888        888          8888888K.           
 8888888b       d88P  888 888        888        888         888            888          888  "Y88b          
 888  Y88b     d88P   888 888        888        888         888            888          888    888          
 888   Y88b   d8888888888 888        888        888     d8b 888        d8b 888      d8b 888   d88P d8b      
 888    Y88b d88P     888 88888888 8888888      888     Y8P 8888888888 Y8P 88888888 Y8P 8888888P"  Y8P
EOF
echo -e "${NC}"

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: Please run as sudo!${NC}"
    exit 1
fi

echo -e "${PURPLE}========================================${NC}"
echo -e "${PURPLE}Software to be installed:${NC}"
echo -e "${PURPLE}========================================${NC}"
echo -e "${GREEN}Development Tools:${NC}"
echo -e "  - python3"
echo -e "  - python3-pip"
echo -e "  - golang"
echo -e "  - nodejs"
echo -e "  - npm"
echo -e "  - build-essential"
echo -e "${GREEN}Network & Recon Tools:${NC}"
echo -e "  - nmap"
echo -e "  - net-tools"
echo -e "  - iputils-ping"
echo -e "  - whois"
echo -e "  - dnsutils (dig)"
echo -e "  - masscan"
echo -e "${GREEN}Exploitation Frameworks:${NC}"
echo -e "  - metasploit-framework"
echo -e "  - sqlmap"
echo -e "  - john"
echo -e "  - hydra"
echo -e "  - exploitdb"
echo -e "${GREEN}Quality of Life Tools:${NC}"
echo -e "  - htop"
echo -e "  - git"
echo -e "  - curl"
echo -e "  - wget"
echo -e "  - vim"
echo -e "  - tmux"
echo -e "${GREEN}WSL Optimizations:${NC}"
echo -e "  - pip symbolic link"
echo -e "  - zsh + oh-my-zsh"
echo -e "  - hack-style prompt"
echo -e "${PURPLE}========================================${NC}"

while true; do
    read -p "$(echo -e "${GREEN}Do you want to proceed with installation? (y/n): ${NC}")" yn
    case $yn in
        [Yy]*) break ;;
        [Nn]*) echo -e "${RED}Installation cancelled.${NC}"; exit ;;
        *) echo -e "${RED}Please answer yes or no.${NC}" ;;
    esac
done

INSTALLED_TOOLS=()

run_task "apt update -y" "Updating package lists..." "Package list update failed!"
run_task "apt full-upgrade -y" "Performing system upgrade..." "System upgrade failed!"

run_task "apt install -y python3 python3-pip golang nodejs npm build-essential" "Installing Development tools..." "Development tools installation failed!"
INSTALLED_TOOLS+=("python3" "python3-pip" "golang" "nodejs" "npm" "build-essential")

run_task "apt install -y nmap net-tools iputils-ping whois dnsutils masscan" "Installing Network & Recon tools..." "Network & Recon tools installation failed!"
INSTALLED_TOOLS+=("nmap" "net-tools" "iputils-ping" "whois" "dig (dnsutils)" "masscan")

run_task "apt install -y metasploit-framework sqlmap john hydra exploitdb" "Installing Exploitation Frameworks..." "Exploitation Frameworks installation failed!"
INSTALLED_TOOLS+=("metasploit-framework" "sqlmap" "john" "hydra" "exploitdb")

if [ ! -f /usr/bin/pip ]; then
    ln -s /usr/bin/pip3 /usr/bin/pip
fi

run_task "apt install -y zsh" "Installing zsh..." "zsh installation failed!"
if [ ! -d "/root/.oh-my-zsh" ]; then
    run_task "sh -c \"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" \"\" --unattended" "Installing oh-my-zsh..." "oh-my-zsh installation failed!"
fi

if ! grep -q "PROMPT='╭─" /root/.zshrc; then
    cat >> /root/.zshrc << EOF

#style prompt
PROMPT='╭─%F{purple}[%F{white}%n%F{purple}@%F{white}%m%F{purple}] - [%F{white}%~%F{purple}]
╰─%F{green}▶%F{cyan}▶%F{white}▶ %f'
EOF
fi

run_task "apt install -y htop git curl wget vim tmux" "Installing Quality of Life tools..." "Quality of Life tools installation failed!"
INSTALLED_TOOLS+=("htop" "git" "curl" "wget" "vim" "tmux")

echo -e ""
echo -e "${PURPLE}========================================${NC}"
echo -e "${PURPLE}[!] Installation Complete!${NC}"
echo -e "${PURPLE}========================================${NC}"
echo -e "${GREEN}Installed tools:${NC}"
for tool in "${INSTALLED_TOOLS[@]}"; do
    echo -e "  - ${tool}"
done
echo -e "${PURPLE}========================================${NC}"

exit 0
