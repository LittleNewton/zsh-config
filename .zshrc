setopt HIST_IGNORE_ALL_DUPS
bindkey -e
WORDCHARS=${WORDCHARS//[\/]}
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
# * DESCRIPTION: Oh-My-Zsh / zsh Configuration File
# * Author: 刘鹏 / Peng Liu
# * Email: littleNewton6@gmail.com
# * Date Created: 2020, Jun.  27
# * Data Updated: 2023, Sept. 25





autoload colors; colors

source ${XDG_CONFIG_HOME}/zsh/functions/get_os_type.zsh
source ${XDG_CONFIG_HOME}/zsh/functions/init_env.zsh
source ${XDG_CONFIG_HOME}/zsh/functions/init_alias.zsh
source ${XDG_CONFIG_HOME}/zsh/functions/init_ohmyzsh.zsh
source ${XDG_CONFIG_HOME}/zsh/functions/init_plugin.zsh
source ${XDG_CONFIG_HOME}/zsh/functions/init_mapping.zsh
source ${XDG_CONFIG_HOME}/zsh/functions/init_conda.zsh
source ${XDG_CONFIG_HOME}/zsh/functions/init_latex.zsh
source ${XDG_CONFIG_HOME}/zsh/functions/os_update.zsh
source ${XDG_CONFIG_HOME}/zsh/functions/enable_k8s_comp.zsh
source ${XDG_CONFIG_HOME}/zsh/functions/enable_pip_comp.zsh
