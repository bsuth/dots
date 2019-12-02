#!/usr/bin/env bash

# startups
ln -sf $DOTS_CORE/.bashrc $HOME/.bashrc
ln -sf $DOTS_CORE/.profile $HOME/.profile
ln -sf $DOTS_CORE/.Xmodmap $HOME/.Xmodmap
ln -sf $DOTS_CORE/.xsession $HOME/.xsession

# awesome
ln -sf $DOTS_CORE/awesome $XDG_CONFIG_HOME/awesome

# nvim
ln -sf  $DOTS_CORE/nvim/settings.vim $XDG_CONFIG_HOME/nvim/settings.vim
ln -sf  $DOTS_CORE/nvim/plugins.vim $XDG_CONFIG_HOME/nvim/plugins.vim
ln -sf  $DOTS_CORE/nvim/mappings.vim $XDG_CONFIG_HOME/nvim/mappings.vim
ln -sf  $DOTS_CORE/nvim/augroups.vim $XDG_CONFIG_HOME/nvim/augroups.vim

# vifm
ln -sf  $DOTS_CORE/vifm/vifmrc $XDG_CONFIG_HOME/vifm/vifmrc
ln -sf  $DOTS_CORE/vifm/scripts $XDG_CONFIG_HOME/vifm/scripts
ln -sf  $DOTS_CORE/vifm/colors $XDG_CONFIG_HOME/vifm/colors
