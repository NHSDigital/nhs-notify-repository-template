#!/bin/bash

cp ./postcreatecommand.sh /postcreatecommand.sh
cp ./zshrc.template /.zshrc

rm -Rf /.asdf

ARCH=$(uname -m)
case "$ARCH" in
  x86_64) ASDF_ARCH="linux-amd64" ;;
  aarch64|arm64) ASDF_ARCH="linux-arm64" ;;
  *) echo "Unsupported architecture: $ARCH" && exit 1 ;;
esac

ASDF_VERSION=$(curl --proto "=https" -fsSL https://api.github.com/repos/asdf-vm/asdf/releases/latest | grep '"tag_name"' | cut -d '"' -f4)
curl --proto "=https" -fL "https://github.com/asdf-vm/asdf/releases/download/${ASDF_VERSION}/asdf-${ASDF_VERSION}-${ASDF_ARCH}.tar.gz" | tar -xz -C /usr/local/bin
asdf version

cat /.zshrc

cp /.zshrc ~/.zshrc
source ~/.zshrc
mkdir -p /zsh/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions /zsh/plugins/zsh-autosuggestions
