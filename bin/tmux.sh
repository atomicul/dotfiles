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
    echo 'Installing tmux...'
    sleep 2
    sudo apt-get install -y tmux

    echo 'Installing fish...'
    sleep 2
    sudo apt-get install -y fish

    echo 'Installing ranger, fzf...'
    sleep 2
    sudo apt-get install -y ranger fzf

    echo 'Installing TPM (Plugin manager)'
    sleep 2
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

    echo 'Installing tmux-sessionizer'
    sudo apt-get install -y cargo
    cargo install tmux-sessionizer
}

configure () {
    cd "$(dirname "$0")/.."

    echo 'Copying .tmux.conf'
    cp ./.tmux.conf "$HOME/"

    echo 'Installing helper script into /usr/local/bin/tmux-shell'
    cat << 'END_OF_FILE' >/tmp/tmux-shell
#!/bin/bash
exec tmux new -A -s 0
END_OF_FILE

    sudo mv /tmp/tmux-shell /usr/local/bin/
    sudo chmod +x /usr/local/bin/tmux-shell

    echo 'Configuring tmux-sessionizer'
    mkdir -p "$HOME/Documents/dev"
    tms config --paths "$HOME/Documents/dev" >/dev/null
    tms config --session 0 >/dev/null
}

main "${@}"
