#/usr/bin/env bash

declare -A commands

commands=(
    [firefox]="firefox"
    [awesome]="st -e vifm $DOTS_CORE/awesome"
    [nvim]="st -e vifm $DOTS_CORE/nvim"
    [vifm]="st -e vifm $DOTS_CORE/vifm"
    [sleep]="systemctl suspend"
    [reboot]="reboot"
    [poweroff]="poweroff"
)

key=$(echo "${!commands[@]}" | tr " " "\n" | dmenu)
eval "${commands[$key]}" & disown
