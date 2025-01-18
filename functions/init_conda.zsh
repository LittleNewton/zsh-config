set_conda() {
    # 定义支持的操作系统类型数组
    supported_os=(
        "Debian"
        "macOS"
        "Manjaro"
        "TrueNAS_SCALE"
        "Ubuntu"
    )

    # 检查当前操作系统是否在支持列表中
    if [[ " ${supported_os[@]} " =~ " ${os_type} " ]]; then
        # >>> conda initialize >>>
        # !! Contents within this block are managed by 'conda init' !!
        __conda_setup=$("$HOME/bin/miniconda3/bin/conda" 'shell.zsh' 'hook' 2>/dev/null)
        if [ $? -eq 0 ]; then
            eval "$__conda_setup"
        else
            if [ -f "$HOME/bin/miniconda3/etc/profile.d/conda.sh" ]; then
                . "$HOME/bin/miniconda3/etc/profile.d/conda.sh"
            else
                export PATH="$HOME/bin/miniconda3/bin:$PATH"
            fi
        fi
        unset __conda_setup
        # <<< conda initialize <<<
    elif [[ "$os_type" == "OpenWrt" ]]; then
        # OpenWrt 不需要 Anaconda 配置
        # No action is needed
        :
    else
        echo "Unsupported OS type: $os_type"
    fi
}

# 执行函数
set_conda
