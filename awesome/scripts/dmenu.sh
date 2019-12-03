#/usr/bin/env bash

#######################################
## HELPERS
#######################################

function blah() {
    physlock -d -p 'This is a message' && systemctl suspend
}


#######################################
## MAIN
#######################################

declare -A commands

commands=(
    [firefox]="firefox"
    [awesome]="st -e vifm $XDG_CONFIG_HOME/awesome"
    [luakit]="st -e vifm $XDG_CONFIG_HOME/luakit"
    [vifm]="st -e vifm $XDG_CONFIG_HOME/vifm"
    [sleep]="blah"
    [reboot]="reboot"
    [poweroff]="poweroff"
)

key=$(echo "${!commands[@]}" | tr " " "\n" | dmenu)
eval "${commands[$key]}" & disown
