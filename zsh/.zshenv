# ------------------------------------------------------------------------------
# General
# ------------------------------------------------------------------------------

export DOTS="$HOME/dots"
export ZDOTDIR="$DOTS/zsh"

export SHELL='/bin/zsh'
export EDITOR=nvim
export WORDCHARS=${WORDCHARS//[\/\.]}
export BROWSER='none'

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export PATH="$HOME/.luarocks/bin:$PATH"

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

# ------------------------------------------------------------------------------
# Lua
# ------------------------------------------------------------------------------

function _generate_lua_path_ {
  declare -a LUA_PATH_PARTS=(
    "./?.lua"
    "./?/init.lua"
    "$HOME/.luarocks/share/lua/$1/?.lua"
    "$HOME/.luarocks/share/lua/$1/?/init.lua"
    "/usr/local/share/lua/$1/?.lua"
    "/usr/local/share/lua/$1/?/init.lua"
    "/usr/share/lua/$1/?.lua"
    "/usr/share/lua/$1/?/init.lua"
    "/usr/lib/lua/$1/?.lua"
    "/usr/lib/lua/$1/?/init.lua"
  )
  GENERATED_LUA_PATH=$(IFS=";"; echo "${LUA_PATH_PARTS[*]}")

  declare -a LUA_CPATH_PARTS=(
    "./?.so"
    "$HOME/.luarocks/lib/lua/$1/?.so"
    "/usr/local/lib/lua/$1/?.so"
    "/usr/lib/lua/$1/?.so"
    "/usr/lib/lua/$1/loadall.so"
  )
  GENERATED_LUA_CPATH=$(IFS=";"; echo "${LUA_CPATH_PARTS[*]}")
}

_generate_lua_path_ "5.4"
export LUA_PATH_5_4="$GENERATED_LUA_PATH"
export LUA_CPATH_5_4="$GENERATED_LUA_CPATH"

_generate_lua_path_ "5.3"
export LUA_PATH_5_3="$GENERATED_LUA_PATH"
export LUA_CPATH_5_3="$GENERATED_LUA_CPATH"

_generate_lua_path_ "5.2"
export LUA_PATH_5_2="$GENERATED_LUA_PATH"
export LUA_CPATH_5_2="$GENERATED_LUA_CPATH"

_generate_lua_path_ "5.1"
export LUA_PATH="$GENERATED_LUA_PATH"
export LUA_CPATH="$GENERATED_LUA_CPATH"

# ------------------------------------------------------------------------------
# Projects
# ------------------------------------------------------------------------------

function erdedev() {
  export ERDE_ROOT="$HOME/repos/erde"
  export LUA_PATH="$ERDE_ROOT/?.lua;$ERDE_ROOT/?/init.lua;$LUA_PATH"
  export LUA_PATH_5_2="$ERDE_ROOT/?.lua;$ERDE_ROOT/?/init.lua;$LUA_PATH_5_2"
  export LUA_PATH_5_3="$ERDE_ROOT/?.lua;$ERDE_ROOT/?/init.lua;$LUA_PATH_5_3"
  export LUA_PATH_5_4="$ERDE_ROOT/?.lua;$ERDE_ROOT/?/init.lua;$LUA_PATH_5_4"

  alias erde="lua $ERDE_ROOT/erde/cli/init.lua"
  alias erdejit="luajit $ERDE_ROOT/erde/cli/init.lua"
  alias erde5.1="lua5.1 $ERDE_ROOT/erde/cli/init.lua"
  alias erde5.2="lua5.2 $ERDE_ROOT/erde/cli/init.lua"
  alias erde5.3="lua5.3 $ERDE_ROOT/erde/cli/init.lua"
  alias erde5.4="lua5.4 $ERDE_ROOT/erde/cli/init.lua"
}

export LUI_ROOT="$HOME/repos/lui"
export LUA_PATH="$LUI_ROOT/?.lua;$LUI_ROOT/?/init.lua;$LUA_PATH"
export LUA_PATH_5_2="$LUI_ROOT/?.lua;$LUI_ROOT/?/init.lua;$LUA_PATH_5_2"
export LUA_PATH_5_3="$LUI_ROOT/?.lua;$LUI_ROOT/?/init.lua;$LUA_PATH_5_3"
export LUA_PATH_5_4="$LUI_ROOT/?.lua;$LUI_ROOT/?/init.lua;$LUA_PATH_5_4"
export PATH="$LUI_ROOT/bin:$PATH"
