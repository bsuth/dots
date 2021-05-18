xmodmap ~/.Xmodmap
eval $(ssh-agent -s)

fcitx

picom -b \
  --no-fading-openclose \
  --no-fading-destroyed-argb \
  --fade-in-step=1 \
  --fade-out-step=1 \
  --inactive-opacity=1

awesome

# vim: syntax=sh
