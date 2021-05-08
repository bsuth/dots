source ~/.zshrc

# required for coc.nvim
export TMPDIR='/tmp'

# autostart x11
if [ -z "${DISPLAY}" ] && [ "${XDG_VTNR}" -eq 1 ]; then
  exec startx
fi
