eval $(ssh-agent -s)

fcitx5 -d
udiskie &
flameshot &

picom -b \
  --no-fading-openclose \
  --no-fading-destroyed-argb \
  --fade-in-step=1 \
  --fade-out-step=1 \
  --frame-opacity=1

exec awesome >> "$HOME/.cache/awesome/stdout" 2>> "$HOME/.cache/awesome/stderr"

# vim: syntax=sh
