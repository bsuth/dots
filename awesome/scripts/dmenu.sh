#/usr/bin/env bash

declare -A commands

commands=(
    [firefox]="firefox"
    [awesome]="st -e vifm $XDG_CONFIG_HOME/awesome"
    [luakit]="st -e vifm $XDG_CONFIG_HOME/luakit"
    [vifm]="st -e vifm $XDG_CONFIG_HOME/vifm"
    [reboot]="reboot"
    [poweroff]="poweroff"
)

key=$(echo "${!commands[@]}" | tr " " "\n" | dmenu)
eval "${commands[$key]}" & disown
