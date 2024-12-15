#!/bin/bash

cd $(dirname "$0")

alias apt-get="apt-get -qq"

apt-get update && apt-get upgrade -y

# Install .bashrc
cp ./.bashrc "$HOME/.bashrc"

# Install nerd font
mkdir -p /tmp/roboto-mono
mkdir -p /usr/local/share/fonts/RobotoMono
wget "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/RobotoMono.zip" -O /tmp/roboto-mono/RobotoMono.zip
sudo unzip /tmp/roboto-mono/RobotoMono.zip -d /usr/local/share/fonts/RobotoMono

# Install usual applications
sudo apt-get install -y xfce4-terminal discord steam lutris google-chrome-stable spotify-client gimp

# Configure i3wm
wget https://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2024.03.04_all.deb -O /tmp/sur5r-keyring_2024.03.04_all.deb
sudo apt-get install /tmp/sur5r-keyring_2024.03.04_all.deb
sudo echo "deb http://debian.sur5r.net/i3/ $(lsb_release -sc) universe" | tee /etc/apt/sources.list.d/sur5r-i3.list
sudo apt-get update
sudo apt-get install -y i3

## i3/config dependencies
sudo apt-get install -y redshift feh playerctl

readarray -t secondary_monitors <<<$(xrandr | grep " connected " | grep -v " primary " | awk '{ print$1 }')
primary_monitor=$(xrandr | grep " primary " | awk '{ print$1 }')

sed -E "$(
	printf '%s%s\n' 's/^(set \$primary-monitor ).*$' "/\\1\"${primary_monitor}\"/gm;t"
)" ./i3/config >/tmp/i3-config

if test ${#secondary_monitors[*]} -lt 1; then
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

sudo apt-get install -y i3status
mkdir -p "$HOME/.config/i3status"
cp ./i3status/config "$HOME/.config/i3status"

sudo apt-get install -y picom
mkdir -p "$HOME/.config/picom"
cp ./picom/picom.conf "$HOME/.config/picom"

sudo apt-get install -y rofi
mkdir -p "$HOME/.config/rofi"
cp ./rofi/config.rasi "$HOME/.config/rofi"

## Install i3lock-color
sudo apt-get install -y autoconf gcc make pkg-config libpam0g-dev libcairo2-dev \
	libfontconfig1-dev libxcb-composite0-dev libev-dev libx11-xcb-dev libxcb-xkb-dev \
	libxcb-xinerama0-dev libxcb-randr0-dev libxcb-image0-dev libxcb-util-dev \
	libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev libjpeg-dev

git clone https://github.com/Raymo111/i3lock-color.git /tmp/i3lock-color
cd /tmp/i3lock-color
sudo bash ./install-i3lock-color.sh
cd $(dirname $0)

# Install tmux
sudo apt-get install -y tmux
