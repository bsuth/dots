xmodmap ~/.Xmodmap
eval $(ssh-agent -s)

fcitx5 -d

picom -b \
  --no-fading-openclose \
  --no-fading-destroyed-argb \
  --fade-in-step=1 \
  --fade-out-step=1 \
  --inactive-opacity=1 \
  --frame-opacity=1

# dbus-launch required for flameshot
# https://wiki.archlinux.org/title/Flameshot
exec dbus-launch awesome

# vim: syntax=sh
