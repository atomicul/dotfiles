#!/bin/bash

cd "$(dirname "$0")/.."

mkdir -p "$HOME/.ssh"
touch "$HOME/.ssh/id_rsa"
cp ./.gitconfig "$HOME"
until
    openssl aes-256-cbc -pbkdf2 -d -in ./.ssh/id_rsa.enc -out "$HOME/.ssh/id_rsa" &&
        chmod 600 "$HOME/.ssh/id_rsa" &&
        ssh-keygen -f "$HOME/.ssh/id_rsa" -y >"$HOME/.ssh/id_rsa.pub" &&
        chmod 600 "$HOME/.ssh/id_rsa.pub"
do
    echo "Try again"
done
