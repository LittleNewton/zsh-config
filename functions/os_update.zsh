function os-update () {
    # (1) 更新 TeX Live
    print -P "%F{cyan}Step 1/3 tlmgr update%f"
    if [[ $is_texlive_installed == "true" ]]; then
        sudo tlmgr update --self --all
    elif [[ $is_texlive_installed == "false" ]]; then
        print -P "%F{white}INFO: No installation of texlive was detected, please check it%f"
    fi

    # (2) 更新 miniconda Python，不使用系统 Python
    print -P "%F{cyan}Step 2/3: Updating Miniconda%f"
    print -P "%F{white}NOTE: Only the base virtual environment will be updated.%f"
    conda activate base
    conda upgrade python --yes
    conda upgrade -n base --yes --all

    # (3) 更新系统包管理器下的软件
    case $os_type in
        macOS)
            print -P "%F{cyan}Step 3/3: Updating macOS Homebrew%f"
            brew update
            brew upgrade
            ;;
        Ubuntu)
            if command -v apt-get >/dev/null 2>&1; then
                print -P "%F{cyan}Step 3/3: Updating Ubuntu%f"

                cmds=(
                    "sudo apt-get update"
                    "sudo apt-get upgrade --just-print"
                    "sudo apt-get upgrade"
                    "sudo apt-get dist-upgrade"
                    "sudo apt-get -y autoremove"
                    "sudo apt-get -y autoclean"
                    "sudo apt-get -y clean"
                )

                for cmd in "${cmds[@]}"; do
                    echo
                    print -P "%F{yellow}> $cmd%f"
                    eval $cmd
                done
            else
                print -P "%F{red}ERROR: System package manager not supported.%f"
            fi
            ;;
        Debian)
            if command -v apt-get >/dev/null 2>&1; then
                print -P "%F{cyan}Step 3/3: Updating Debian%f"

                cmds=(
                    "sudo apt-get update"
                    "sudo apt-get upgrade --just-print"
                    "sudo apt-get upgrade"
                    "sudo apt-get dist-upgrade"
                    "sudo apt-get -y autoremove"
                    "sudo apt-get -y autoclean"
                    "sudo apt-get -y clean"
                )

                for cmd in "${cmds[@]}"; do
                    echo
                    print -P "%F{yellow}> $cmd%f"
                    eval $cmd
                done
            else
                print -P "%F{red}ERROR: System package manager not supported.%f"
            fi
            ;;
        RedHat)
            if command -v yum >/dev/null 2>&1; then
                echo $fg[cyan]Step 3/3: Updating RedHat$reset_color
                sudo yum update
            else
                print -P "%F{red}ERROR: System package manager not supported.%f"
            fi
            ;;
        *)
            print -P "%F{red}ERROR: Unsupported operating system: $os_type.%f"
            ;;
    esac
}
