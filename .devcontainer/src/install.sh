#!/bin/bash

cp ./postcreatecommand.sh /postcreatecommand.sh
cp ./zshrc.template /.zshrc

rm -Rf /.asdf
ASDF_VERSION=$(curl --proto "=https" -fsSL https://api.github.com/repos/asdf-vm/asdf/releases/latest | grep '"tag_name"' | cut -d '"' -f4)
curl --proto "=https" -fL "https://github.com/asdf-vm/asdf/releases/download/${ASDF_VERSION}/asdf-${ASDF_VERSION}-linux-amd64.tar.gz" | tar -xz -C /usr/local/bin
asdf version

cat /.zshrc

cp /.zshrc ~/.zshrc
source ~/.zshrc
mkdir -p /zsh/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions /zsh/plugins/zsh-autosuggestions
