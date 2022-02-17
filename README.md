# dots

- [Setup](#setup)
- [Screenshots](#features)
- [Dynamic Awesomewm Tags as Tabs](#dynamic-awesomewm-tags-as-tabs)
- [Using Neovim as a Terminal](#using-neovim-as-a-terminal)

## Setup

### Desktop

- Window Manager: [awesomewm](https://awesomewm.org/index.html)
- Compositor: [picom](https://github.com/yshui/picom)
- Lock: [physlock](https://github.com/muennich/physlock)

### Terminal

- Terminal: [st](https://st.suckless.org)
- Text Editor: [neovim](https://neovim.io)
- Shell: [zsh](https://www.zsh.org)
- Prompt: [spaceship](https://spaceship-prompt.sh)

#### Misc

- Browser: [vivaldi](https://vivaldi.com)
- Color Scheme: [melange](https://github.com/savq/melange)
- Wallpapers: [cysketch](https://twitter.com/cysketch)

## Screenshots

![screenshot1](https://github.com/bsuth/dots/raw/master/assets/readme1.png)
![screenshot2](https://github.com/bsuth/dots/raw/master/assets/readme2.png)
![screenshot3](https://github.com/bsuth/dots/raw/master/assets/readme3.png)
![screenshot4](https://github.com/bsuth/dots/raw/master/assets/readme4.png)

## Dynamic Awesomewm Tags as Tabs

Most information that would normally be displayed in a statusbar (battery, 
volume, brightness) is instead toggled via a popup (see screenshots above). 
Instead, the statusbar is replaced with a 'tagbar'. It displays the available
awesomewm tags (awesomewm's version of virtual desktops), as well as the current 
tag being viewed. Similar to browser tabs, tags can be dynamically added, 
removed, cycled through, and even renamed! I have found this to be much more 
productive and easier to manage than the more common numbered tags, as the tag 
name itself is enough to remember which clients are on which tags.

## Using Neovim as a Terminal

When my terminal emulator spawns, it immediately launches into neovim and 
launches [dirvish](https://github.com/justinmk/vim-dirvish). This, along with
other bindings and occasionally [telescope](https://github.com/nvim-telescope/telescope.nvim)
allow me to move around my files quite quickly. When I want to _actually_ use
my terminal, I use neovim's terminal mode to spawn a terminal emulator inside a
vim buffer. While this is natively a bit awkward to use, with some configuration 
it yields a seamless terminal experience that still allows me to use neovim
bindings when manipulating terminal text. When the shell instance is terminated, 
neovim simply pops back into dirvish.

As an additional benefit, since terminal scrollback is achieved by simply 
scrolling though the vim buffer, the only feature I really need from my terminal
emulator is to display text correctly. For this reason, I use st terminal, 
without even scrollback patches applied. This allows my terminal emulator to 
have an extremely fast startup.
