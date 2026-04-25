#!/usr/bin/bash

# Description: Symlink all dotfiles that are not related to sway.
. lib/utils.sh

set -euo pipefail

declare -A CONF_FILES=( [vim]="$HOME/.vimrc" )

apt_update
# TODO: only if vim is in CONF_FILES keys:
apt_install vim vim-addon-manager vim-youcompleteme
vim-addon-manager install youcompleteme

printf "\nCreating symbolic links for dotfiles files from this repo:\n"

# install dotfiles from this repo via symlink to facilitate updates
for prog in "${!CONF_FILES[@]}"; do
    ln -fvs "$PWD/configs/$prog/config" "${CONF_FILES[$prog]}"
done

echo "Installation done."
