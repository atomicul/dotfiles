#!/bin/bash

function main () {
    cd $(dirname "$0")

    if yes_or_no 'Get ssh keys (requires decryption password)'
    then
        bin/ssh-keys.sh
    fi

    sudo apt-get update && sudo apt-get upgrade -y

    # Install keyboard
    cp ./keyboard /tmp/keyboard \
        && sudo mv /tmp/keyboard /etc/default/keyboard

    bin/i3wm.sh

    bin/tmux.sh

    bin/nvim.sh
}

function yes_or_no () {
    while true; do
        read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) return 0  ;;  
            [Nn]*) echo "Aborted" ; return  1 ;;
        esac
    done
}

main "${@}"
