#!/bin/bash

FONT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
RESTORE_DIR="$(pwd)"

cd "$FONT_DIR"

(ls *.ttf >/dev/null 2>&1) && sudo cp *.ttf /usr/local/share/fonts
(ls *.otf >/dev/null 2>&1) && sudo cp *.otf /usr/local/share/fonts
fc-cache

cd "$RESTORE_DIR"
