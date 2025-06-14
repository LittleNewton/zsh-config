# My Zsh config

# Prerequisite

First of all, please make sure your ZDGDesktop type variables are set. If not, please invoke those commands:

``` zsh
tee ${HOME}/.zshenv >/dev/null 2>/dev/null << "EOF"
# XDG path
export XDG_CONFIG_HOME="$HOME/.config"
export   XDG_DATA_HOME="$HOME/.local/share"
export  XDG_CACHE_HOME="$HOME/.cache"

# Zsh related config file.
export  ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export HISTFILE="$ZDOTDIR/.zhistory"    # History filepath
export HISTSIZE=10000                   # Maximum events for internal history
export SAVEHIST=10000                   # Maximum events in history file

# Zim related config file.
export ZIM_HOME="$XDG_DATA_HOME/zim"
EOF

source ~/.zshenv
```
## Installation

### Normal

If this is the first time you are installing the zsh environment, you can simply run the following command. Then, without any further manual effort, you can get a nice zsh environment.

``` zsh
git clone https://github.com/LittleNewton/zsh-config.git ~/.config/zsh
```

If you want to recover your old zsh history, you should `cp ~/.zsh_history ${XDG_CONFIG_HOME/zsh/.zhistory}`

### SSH config

`remote-exe` command needs a well defined `~/.ssh/config`. An example, customized for myself, is provided in [`config/ssh_entries`](/config/ssh_entries). This command should work great with my workflow.

``` bash
cp ~/.config/zsh/config/ssh_entries ~/.ssh/config
```

### Docker Environment

If you are in a Docker environment, please run those commands first. [Here](https://github.com/deluan/zsh-in-docker) is the reference.

``` zsh
sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.1/zsh-in-docker.sh)"
rm -fr ${HOME}/.config/zsh && git clone https://github.com/LittleNewton/zsh-config.git ~/.config/zsh
```

### Automatic completion

正常情况下无需手动执行该命令。

如果修改了 `ltnt_install` 函数的内容，或者想要手动添加补全功能，可以执行以下命令：

```
tee "$HOME/.config/zsh/completion/_ltnt_install" > /dev/null << 'EOF'
# 自动补全函数
function _ltnt_install_completion() {
    local cur_word supported_packages
    cur_word="$words[2]"
    supported_packages=(
        "all"
        "joshuto"
        "lazygit"
        "neovim"
        "yazi"
    )

    # 生成补全列表
    compadd -- "${supported_packages[@]}"
}

# 绑定补全函数到 ltnt_install
compdef _ltnt_install_completion ltnt_install
EOF
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
