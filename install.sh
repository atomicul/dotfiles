#!/bin/bash

function yes_or_no {
    while true; do
        read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) return 0  ;;  
            [Nn]*) echo "Aborted" ; return  1 ;;
        esac
    done
}

cd $(dirname "$0")
script_dir=$(pwd)

yes_or_no 'Get ssh keys (requires decryption password)'
if test $? -eq 0; then
    mkdir -p "$HOME/.ssh"
    touch "$HOME/.ssh/id_rsa"
    cp ./.gitconfig "$HOME"
    until \
        openssl aes-256-cbc -pbkdf2 -d -in ./.ssh/id_rsa.enc -out "$HOME/.ssh/id_rsa" && \
            chmod 600 "$HOME/.ssh/id_rsa"  && \
            ssh-keygen -f "$HOME/.ssh/id_rsa" -y > "$HOME/.ssh/id_rsa.pub" && \
            chmod 600 "$HOME/.ssh/id_rsa.pub" 
    do
        echo "Try again"
    done
fi

alias apt-get="apt-get -qq"

sudo apt-get update && sudo apt-get upgrade -y

# Install .bashrc
cp ./.bashrc "$HOME/.bashrc"

# Install keyboard
cp ./keyboard /tmp/keyboard \
    && sudo mv /tmp/keyboard /etc/default/keyboard

# Install nerd font
mkdir -p /tmp/roboto-mono
sudo mkdir -p /usr/local/share/fonts/RobotoMono
wget "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/RobotoMono.zip" -O /tmp/roboto-mono/RobotoMono.zip
sudo unzip /tmp/roboto-mono/RobotoMono.zip -d /usr/local/share/fonts/RobotoMono

# Install usual applications
curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt-get update
sudo apt-get install -y xfce4-terminal discord steam lutris google-chrome-stable spotify-client gimp

# Configure i3wm
wget https://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2024.03.04_all.deb -O /tmp/sur5r-keyring_2024.03.04_all.deb
sudo apt-get install /tmp/sur5r-keyring_2024.03.04_all.deb
echo "deb http://debian.sur5r.net/i3/ $(lsb_release -sc) universe" | sudo tee /etc/apt/sources.list.d/sur5r-i3.list
sudo apt-get update
sudo apt-get install -y i3

## i3/config dependencies
sudo apt-get install -y redshift feh playerctl

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
bash ./install-i3lock-color.sh
cd "$script_dir"

# Install tmux
sudo apt-get install -y tmux
## Tmux dependencies
sudo apt-get install -y ranger fzf
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cp ./.tmux.conf "$HOME/"

echo \
	'#!/bin/bash
(tmux attach || tmux new-session) && exit' \
	>/tmp/tmux-shell
sudo mv /tmp/tmux-shell /usr/local/bin/
sudo chmod +x /usr/local/bin/tmux-shell

# Tmux sessionizer
sudo apt-get install -y cargo
cargo install tmux-sessionizer
mkdir -p "$HOME/Documents/dev"
tms config --paths "$HOME/Documents/dev"
tms config --session 0

# Install nvim
cd /tmp
wget 'https://github.com/neovim/neovim/releases/download/v0.10.2/nvim-linux64.tar.gz' -O ./nvim-linux64.tar.gz
tar xzvf ./nvim-linux64.tar.gz
sudo mv ./nvim-linux64 /opt
sudo mv /opt/nvim-linux64/lib/nvim/parser /opt/nvim-linux64/lib/nvim/_parser
sudo ln -sn /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
cd "$script_dir"

## nvim dependencies
sudo apt-get install -y ripgrep
cd /tmp
wget 'https://github.com/jesseduffield/lazygit/releases/download/v0.44.1/lazygit_0.44.1_Linux_x86_64.tar.gz' -O ./lazy-git.tar.gz
tar xzvf ./lazy-git.tar.gz
sudo cp lazygit /opt
sudo ln -sn /opt/lazygit /usr/local/bin/lazygit
cd "$project_dir"

cp -r ./nvim "$HOME/.config/"
sudo mkdir -p /root/.config
sudo ln -s "$HOME/.config/nvim" /root/.config/nvim

# Other packages
sudo apt-get install -y btop bat xclip neofetch

## docker
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

## docker daemonizer
mkdir -p "$HOME/.local/bin"
cp ./daemonize-docker "$HOME/.local/bin"
chmod +x "$HOME/.local/bin/daemonize-docker"
