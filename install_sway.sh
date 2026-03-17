#!/usr/bin/bash

# Install all required packages for sway and symlink the dotfiles.
set -euo pipefail

SWAY_CONF_DIR="$HOME/.config/sway"
SWAY_RUN_DIR="/usr/local/bin"
KANSHI_CONF_DIR="$HOME/.config/kanshi"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"

# get the systemd unit's current state 
get_unit_state () {
    local unit_state=$(systemctl --user list-unit-files "$1" \
        --output json --no-pager | jq '.[].state') 

    if [[ $unit_state == "" ]]; then
        echo "missing"
    else
        echo "$unit_state" 
    fi
}

# execute necessary commands to initialise systemd unit based on state
init_unit () { 
    local state=$(get_unit_state $1) 
    local unit_file_repo="$2/$1"
    local unit_type=${1##*.}
    echo "State of $1: $state"
    # don't enable target units
    case "$state" in
        missing) ln -fvs $unit_file_repo $3;&
        disabled)
            if [[ "${unit_type}" != target ]]; then
                systemctl --user enable $1
            fi     
            ;;
        *)
            echo "Systemd unit $1 is already installed. Doing nothing."
            return;;
    esac
}

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
    xdg-desktop-portal xdg-desktop-portal-wlr \
    blueman libspa-0.2-bluetooth

# install sway config from this repo via symlink to facilitate updates
printf "\nCreating symbolic links for the config files from this repo:\n"
ln -fvs "$PWD/configs/sway/config" "$SWAY_CONF_DIR/config"
sudo ln -fvs "$PWD/scripts/sway-run" "$SWAY_RUN_DIR/sway-run"

printf "\nCreating symbolic links and initalizing systemd units for sway:\n"
init_unit "sway-session.target" "$PWD/configs/sway" $SYSTEMD_USER_DIR
init_unit "kanshi.service" "$PWD/configs/sway" $SYSTEMD_USER_DIR 

# install kanshi config via symlink
ln -fvs "$PWD/configs/kanshi/config" "$KANSHI_CONF_DIR/config"

echo "Installation done."
