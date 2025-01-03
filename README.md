# My Zsh config

# Prerequisite

First of all, please make sure your ZDGDesktop type variables are set. If not, please:

``` zsh
echo '# XDG 规范的路径
export XDG_CONFIG_HOME="$HOME/.config"
export   XDG_DATA_HOME="$HOME/.local/share"
export  XDG_CACHE_HOME="$HOME/.cache"

# Zsh related config file.
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export HISTFILE="$ZDOTDIR/.zhistory"    # History filepath
export HISTSIZE=10000                   # Maximum events for internal history
export SAVEHIST=10000                   # Maximum events in history file

# Zim related config file.
export ZIM_HOME="$XDG_DATA_HOME/zim"' > ~/.zshenv && source ~/.zshenv
```
## Installation

If this is the first time you install zsh environment, you can simply run the folowing command. Without any furthor manually effort, you can get a nice zsh environment.

``` zsh
git clone https://github.com/LittleNewton/zsh-config.git ~/.config/zsh
```
If you want to recover your old zsh history, you can `cp ~/.zsh_history ${XDG_CONFIG_HOME/zsh/.zhistory}`

If you are in an docker environment, please run this command first. [Here](https://github.com/deluan/zsh-in-docker) is the reference.

``` zsh
sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.1/zsh-in-docker.sh)"
git clone https://github.com/LittleNewton/zsh-config.git ~/.config/zsh
```

## Other utility

``` zsh
cd $HOME
GITHUB="https://github.com/LittleNewton"
git clone ${GITHUB}/joshuto-config          ~/.config/joshuto
git clone ${GITHUB}/lazygit-config          ~/.config/lazygit
git clone ${GITHUB}/tmux-config             ~/.config/tmux
git clone ${GITHUB}/tmux-powerline-config   ~/.config/tmux-powerline
git clone ${GITHUB}/btop-config.git         ~/.config/btop
```
