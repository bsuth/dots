xmodmap ~/.Xmodmap
eval $(ssh-agent -s)

fcitx5 -d
udiskie &

picom -b \
  --no-fading-openclose \
  --no-fading-destroyed-argb \
  --fade-in-step=1 \
  --fade-out-step=1 \
  --inactive-opacity=1 \
  --frame-opacity=1

exec awesome >> ~/.cache/awesome/stdout 2>> ~/.cache/awesome/stderr

# vim: syntax=sh
