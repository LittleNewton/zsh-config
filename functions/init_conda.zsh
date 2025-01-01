set_conda() {
    case $os_type in
        "Debian" | "Ubuntu" | "Manjaro" | "TrueNAS_SCALE" | "macOS")
            # >>> conda initialize >>>
            # !! Contents within this block are managed by 'conda init' !!
            __conda_setup=$("$HOME/bin/miniconda3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)
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
            ;;
        
        "OpenWrt")
            # OpenWrt 不需要 Anaconda 配置
            # No action needed
            ;;
        
        *)
            echo "Unsupported OS type: $os_type"
            ;;
    esac
}

# 执行函数
set_conda;

