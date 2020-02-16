xmodmap $HOME/.Xmodmap
compton -b
fcitx -d -r 2>/dev/null || true
exec awesome
