#!/bin/bash

main () {
    if [ $# -eq 0 ]; then
        install && configure && exit 0
    elif [ $# -eq 1 ]; then
        if [ "$1" = "install" ]; then
            install && exit 0
        elif [ "$1" = "configure" ]; then
            configure && exit 0
        fi
    fi

    1>&2 echo "USAGE: $0 [install | configure]"
    exit 1
}

install () {
    clear
    echo 'Installing a NerdFont...'
    sleep 2
    mkdir -p /tmp/roboto-mono
    sudo mkdir -p /usr/local/share/fonts/RobotoMono
    wget "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/RobotoMono.zip" -O /tmp/roboto-mono/RobotoMono.zip
    sudo unzip /tmp/roboto-mono/RobotoMono.zip -d /usr/local/share/fonts/RobotoMono

    clear
    echo 'Installing i3wm...'
    sleep 2
    sudo apt-get install -y i3 i3status picom rofi

    clear
    echo 'Installing redshift, feh, playerctl'
    sleep 2
    sudo apt-get install -y redshift feh playerctl

    clear
    echo 'Installing i3lock-color'
    sleep 2
    sudo apt-get install -y autoconf gcc make pkg-config libpam0g-dev libcairo2-dev \
        libfontconfig1-dev libxcb-composite0-dev libev-dev libx11-xcb-dev libxcb-xkb-dev \
        libxcb-xinerama0-dev libxcb-randr0-dev libxcb-image0-dev libxcb-util-dev \
        libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev libjpeg-dev
    git clone https://github.com/Raymo111/i3lock-color.git /tmp/i3lock-color
    cd /tmp/i3lock-color
    bash ./install-i3lock-color.sh
    cd -
}

configure () {
    cd "$(dirname "$0"/..)"

    clear
    echo "Copying i3wm config files..."
    sleep 2

    readarray -t secondary_monitors <<<$(xrandr | grep " connected " | grep -v " primary " | awk '{ print$1 }')
    primary_monitor=$(xrandr | grep " primary " | awk '{ print$1 }')

    sed -E "$(
        printf '%s%s\n' 's/^(set \$primary-monitor ).*$' "/\\1\"${primary_monitor}\"/gm;t"
    )" ./i3/config >/tmp/i3-config

    if test -z "${secondary_monitors[*]}"; then
        sed -E -i 's/^(set \$secondary-monitor ).*$//gm;t' /tmp/i3-config
        sed -E -i 's/^bindsym \$mod\+Ctrl\+[0-9].*$//gm;t' /tmp/i3-config
    else
        sed -E -i "$(
            printf '%s%s\n' 's/^(set \$secondary-monitor ).*$' "/\\1\"${secondary_monitors[0]}\"/gm;t"
        )" /tmp/i3-config
    fi

    mkdir -p "$HOME/.config/i3"
    mv /tmp/i3-config "$HOME/.config/i3/config"
    cp ./i3/lock-screen.sh "$HOME/.config/i3"
    cp ./i3/background* "$HOME/.config/i3"

    mkdir -p "$HOME/.config/i3status"
    cp ./i3status/config "$HOME/.config/i3status"

    mkdir -p "$HOME/.config/picom"
    cp ./picom/picom.conf "$HOME/.config/picom"

    mkdir -p "$HOME/.config/rofi"
    cp ./rofi/config.rasi "$HOME/.config/rofi"
}

main "${@}"
