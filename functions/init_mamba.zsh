set_mamba() {
    # 定义支持的操作系统类型数组
    supported_os=(
        "macOS"
    )
    unsupported_os=(
        "Debian"
        "Manjaro"
        "OpenWrt"
        "TrueNAS_SCALE"
        "Ubuntu"
    )

    # 检查当前操作系统是否在支持列表中
    if [[ " ${supported_os[@]} " =~ " ${os_type} " ]]; then
            # >>> mamba initialize >>>
            # !! Contents within this block are managed by 'micromamba shell init' !!
            export MAMBA_EXE='/opt/homebrew/bin/micromamba';
            export MAMBA_ROOT_PREFIX="$HOME/.local/share/micromamba";
            __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
            if [ $? -eq 0 ]; then
            eval "$__mamba_setup"
            else
            alias micromamba="$MAMBA_EXE"  # Fallback on help from micromamba activate
            fi
            unset __mamba_setup
            # <<< mamba initialize <<<
            micromamba activate ${DEFAULT_MAMBA_ENV}
    elif [[ " ${unsupported_os[@]} " =~ " ${os_type} " ]]; then
        # Unsupported OS types do not require Conda configuration
        # No action is needed
        :
    else
        echo "Unsupported OS type: $os_type"
    fi
}

# execute the function
set_mamba
