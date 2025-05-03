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
    cd /tmp

    echo 'Installing nvim...'
    sleep 2
    wget 'https://github.com/neovim/neovim/releases/download/v0.10.2/nvim-linux64.tar.gz' -O ./nvim-linux64.tar.gz
    tar xzvf ./nvim-linux64.tar.gz
    sudo mv ./nvim-linux64 /opt
    sudo mv /opt/nvim-linux64/lib/nvim/parser /opt/nvim-linux64/lib/nvim/_parser
    sudo ln -sn /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim

    echo 'Installing ripgrep, fzf...'
    sleep 2
    sudo apt-get install -y ripgrep fzf

    echo 'Installing lazygit...'
    sleep 2
    wget 'https://github.com/jesseduffield/lazygit/releases/download/v0.44.1/lazygit_0.44.1_Linux_x86_64.tar.gz' -O ./lazy-git.tar.gz
    tar xzvf ./lazy-git.tar.gz
    sudo cp lazygit /opt
    sudo ln -sn /opt/lazygit /usr/local/bin/lazygit
}

configure () {
    cd "$(dirname "$0")/.."

    echo "Copying neovim configs"
    cp -r ./nvim "$HOME/.config/"

    echo "Making a symbolic link for the root user as well"
    sudo mkdir -p /root/.config
    sudo ln -s "$HOME/.config/nvim" /root/.config/nvim
}

main "${@}"
