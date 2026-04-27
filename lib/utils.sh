# Library that holds utility functions.
# Can be included using source lib/utils.sh 

# Get the systemd unit's current state. 
# $1: Name of the unit 
get_unit_state () {
    local unit_state=$(systemctl --user list-unit-files "$1" \
        --output json --no-pager | jq '.[].state') 

    if [[ $unit_state == "" ]]; then
        echo "missing"
    else
        echo "$unit_state" 
    fi
}

# Execute necessary commands to initialise a systemd unit based on its state.
# $1: Name of the unit
# $2: Source directory in this repo where $1 can be found 
# $3: Destination directory on the system where $1 should be linked to
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
            return 0 
            ;;
        *)
            echo "Systemd unit $1 is already installed. Doing nothing."
            return 0;;
    esac
}

# Update package information.
apt_update () {
    sudo apt-get -qq update
}

# Install packages specified in the arguments using apt.
# Make sure to run apt_update() before this function.
# $@: Packages to install, at least on package name must be passed
apt_install () {
    if [[ $# < 1 ]]; then
        printf "At least one package name must be passed."
        return 1;
    fi

    sudo apt-get -q install "$@"
}

# Check if the string $1 is contained in the remaining strings $2 - $#.
contains () {
    local elem search_term=$1 
    shift
    local -a arr=( "$@" )
    for elem in $arr; do [[ "$elem" == "$search_term" ]] && return 0; done 
    return 1
}
