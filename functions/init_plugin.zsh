init_ohmyzsh() {
    # 定义安装路径
    local ohmyzsh_path="${XDG_DATA_HOME}/oh-my-zsh"

    # 检查 `XDG_DATA_HOME` 是否定义
    if [[ -z "${XDG_DATA_HOME}" ]]; then
        echo "ERROR: XDG_DATA_HOME is not defined. Please set it before running this script."
        return 1
    fi

    # 检查目标路径是否存在
    if [[ -d "${ohmyzsh_path}" ]]; then
        return 0
    else
        # 如果路径不存在，则克隆仓库
        echo "oh-my-zsh is not found. Cloning to ${ohmyzsh_path}..."
        if ! git clone https://github.com/ohmyzsh/ohmyzsh.git "${ohmyzsh_path}"; then
            echo "ERROR: Failed to clone oh-my-zsh."
            return 1
        fi
        echo "oh-my-zsh has been installed successfully at ${ohmyzsh_path}."
    fi
}

# 调用函数
init_ohmyzsh

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
for key in '^[[A' '^P' ${terminfo[kcuu1]}; do
    bindkey ${key} history-substring-search-up
done

for key in '^[[B' '^N' ${terminfo[kcud1]}; do
    bindkey ${key} history-substring-search-down
done

for key in 'k'; do
    bindkey -M vicmd ${key} history-substring-search-up
done

for key in 'j'; do
    bindkey -M vicmd ${key} history-substring-search-down
done
unset key

zstyle ':zim:prompt-pwd:fish-style' dir-length 0
export PWD_COLOR=blue
