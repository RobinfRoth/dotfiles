#!/usr/bin/bash

# Install all required packages for sway and symlink the dotfiles.
set -euo pipefail

SWAY_CONF_DIR="$HOME/.config/sway"
SWAY_RUN_DIR="/usr/local/bin"

echo "Running sway install script ..."

# update package information 
sudo apt-get -qq update

# install display manager and greeter
printf "Installing display manager and greeter:\n"
sudo apt-get -qy install greetd tuigreet

# install required packages for config to work
printf "\nInstalling sway and used dependencies:\n"
sudo apt-get -qy install sway swayidle \
    waybar \
    wlsunset \
    kitty \
    dolphin \
    kwallet6 kwalletmanager libpam-kwallet5 \
    network-manager network-manager-applet \
    wmenu j4-dmenu-desktop \
    kanshi \
    grim slurp \
    pulseaudio pulseaudio-utils pulsemixer \
    xwayland \
    light \
    mako-notifier \
    xdg-desktop-portal xdg-desktop-portal-wlr

# install sway config from this repo via symlink to facilitate updates
printf "\nCreate symbolic links for the config files from this repo:\n"
ln -fvs "$PWD/configs/sway/config" "$SWAY_CONF_DIR/config"
sudo ln -fvs "$PWD/scripts/sway-run" "$SWAY_RUN_DIR/sway-run"

echo "Done."
