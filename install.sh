#!/bin/sh

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

install_pacaur(){
    mkdir -p /tmp/pacaur_install
    cd /tmp/pacaur_install
    
    sudo pacman -S binutils make gcc fakeroot pkg-config --noconfirm --needed
    sudo pacman -S expac yajl git --noconfirm --needed
    
    if [ ! -n "$(pacman -Qs cower)" ]; then
        curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=cower
        makepkg PKGBUILD --skippgpcheck --install --needed
    fi

    if [ ! -n "$(pacman -Qs pacaur)" ]; then
        curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=pacaur
        makepkg PKGBUILD --install --needed
    fi

    cd ~
    rm -r /tmp/pacaur_install 
}

install_tldr(){
    if [ ! -e /usr/local/bin/tldr ]; then
        echo "[+] Installing tldr..."
        location=/usr/local/bin/tldr
        sudo wget -qO $location https://raw.githubusercontent.com/pepa65/tldr-bash-client/master/tldr
        sudo chmod +x $location
        $location --update
    fi
}

arch_linux_gui_dependent(){
    pacaur -S terminator --needed --noconfirm
}

# Arch Linux
arch_linux_install(){
    echo "[+] Updating..."
    sudo pacman -Syu --noconfirm
    sudo pacman -S curl wget gvim nano --needed --noconfirm

    if [ -z "$(pacman -Qs pacaur)" ]; then
        echo "[+] Installing pacaur..."
        install_pacaur
    fi
    
    pacaur -S base-devel --needed --noconfirm
    pacaur -S tree --needed --noconfirm
    pacaur -S git python2-pip --needed --noconfirm
    pacaur -S yadm-git --needed --noconfirm
    pacaur -S tmux --needed --noconfirm
    install_tldr
    pacaur -S autojump --needed --noconfirm
    pacaur -S nmap --needed --noconfirm    

    printf "${GREEN}Should install GUI dependent packages? [y/N]: ${NC}"
    read ans
    ans=${ans:-N}

    if [ $ans = "y" -o $ans = "Y" ]; then
        arch_linux_gui_dependent
    fi
}

ubuntu_linux_gui_dependent(){
    sudo apt install terminator -y
    sudo apt install j4-dmenu-desktop
}

ubuntu_install_yadm(){
    sudo apt install -y software-properties-common
    sudo add-apt-repository -y ppa:flexiondotorg/yadm
    sudo apt update
    sudo apt -y install yadm
}

# Ubuntu Linux
ubuntu_linux_install(){
    echo "[+] Updating..."
    sudo apt update && sudo apt upgrade -y
    sudo apt install curl wget vim-gtk -y
    sudo apt install build-essential -y
    sudo apt install tree -y
    sudo apt install git python-pip
    sudo apt install tmux -y
    ubuntu_install_yadm
        install_tldr
    sudo apt install autojump -y
    sudo apt install nmap -y
    printf "${GREEN}Should install GUI dependent packages? [y/N]: ${NC}"
    read ans
    ans=${ans:-N}

    if [ $ans = "y" -o $ans = "Y" ]; then
        ubuntu_linux_gui_dependent
    fi
} 

dotfiles_install(){
    yadm clone https://github.com/viniciusmarangoni/dotfiles
    yadm reset --hard origin/master
    yadm status
}

##############################
#######   Entrypoint   #######
##############################

if [ "$EUID" = "0" ]; then
    echo -e "${RED}[-] You shoul'd not execute this script as root!${NC}"
    exit 1
fi

# Source variables in os-release
. /etc/os-release

if [ "$NAME" = "Arch Linux" ]; then
    arch_linux_install
elif [ "$NAME" = "Ubuntu" ]; then
    ubuntu_linux_install
fi

dotfiles_install
