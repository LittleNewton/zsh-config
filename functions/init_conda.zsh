set_conda() {
    if [[ $os_type == "TrueNAS_SCALE" ]]; then



        # >>> conda initialize >>>
        # !! Contents within this block are managed by 'conda init' !!
        local __conda_setup="$('/mnt/Intel_750_RAID-Z1/newton/bin/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
        if [ $? -eq 0 ]; then
            eval "$__conda_setup"
        else
            if [ -f "/mnt/Intel_750_RAID-Z1/newton/bin/miniconda3/etc/profile.d/conda.sh" ]; then
                . "/mnt/Intel_750_RAID-Z1/newton/bin/miniconda3/etc/profile.d/conda.sh"
            else
                export PATH="/mnt/Intel_750_RAID-Z1/newton/bin/miniconda3/bin:$PATH"
            fi
        fi
        unset __conda_setup
        # <<< conda initialize <<<



    elif [[ $os_type == "Debian" ]]; then



        # >>> conda initialize >>>
        # !! Contents within this block are managed by 'conda init' !!
        __conda_setup="$('/home/newton/bin/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
        if [ $? -eq 0 ]; then
            eval "$__conda_setup"
        else
            if [ -f "/home/newton/bin/miniconda3/etc/profile.d/conda.sh" ]; then
                . "/home/newton/bin/miniconda3/etc/profile.d/conda.sh"
            else
                export PATH="/home/newton/bin/miniconda3/bin:$PATH"
            fi
        fi
        unset __conda_setup
        # <<< conda initialize <<<



    elif [[ $os_type == "macOS" ]]; then

        # >>> conda initialize >>>
        # !! Contents within this block are managed by 'conda init' !!
        __conda_setup="$('/Users/newton/bin/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
        if [ $? -eq 0 ]; then
            eval "$__conda_setup"
        else
            if [ -f "/Users/newton/bin/miniconda3/etc/profile.d/conda.sh" ]; then
                . "/Users/newton/bin/miniconda3/etc/profile.d/conda.sh"
            else
                export PATH="/Users/newton/bin/miniconda3/bin:$PATH"
            fi
        fi
        unset __conda_setup
        # <<< conda initialize <<<



    else
        echo "Unsupported OS type: $os_type"
    fi
}
set_conda;
