init_ohmyzsh() {
    # Check if `XDG_DATA_HOME` is defined
    if [[ -z "${XDG_DATA_HOME}" ]]; then
        echo "ERROR: XDG_DATA_HOME is not defined."
        return 1
    fi

    # check if ${XDG_DATA_HOME}/oh-my-zsh exists
    if [[ -d "${XDG_DATA_HOME}/oh-my-zsh" ]]; then
        return 0
    else
        echo "${XDG_DATA_HOME}/oh-my-zsh not exists,"
        echo "now clone oh-my-zsh to ${XDG_DATA_HOME}/oh-my-zsh."
        git clone https://github.com/ohmyzsh/ohmyzsh.git "${XDG_DATA_HOME}/oh-my-zsh"
        echo "clone oh-my-zsh done."
    fi
}

init_ohmyzsh;



# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi

# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZDOTDIR:-${HOME}}/.zimrc ]]; then
    source ${ZIM_HOME}/zimfw.zsh init -q
fi

source ${ZIM_HOME}/init.zsh


# Bind ^[[A/^[[B manually so up/down works both before and after zle-line-init
zmodload -F zsh/terminfo +p:terminfo
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
for key ('k') bindkey -M vicmd ${key} history-substring-search-up
for key ('j') bindkey -M vicmd ${key} history-substring-search-down
unset key

zstyle ':zim:prompt-pwd:fish-style' dir-length 0
export PWD_COLOR=blue
