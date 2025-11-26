function os-update () {
    # (1) 更新 TeX Live
    print -P "%F{cyan}Step 1/4: tlmgr update%f"
    if [[ $is_texlive_installed == "true" ]]; then
        sudo tlmgr update --self --all
    elif [[ $is_texlive_installed == "false" ]]; then
        print -P "%F{white}INFO: No installation of texlive was detected, please check it%f"
    fi

    # (2) 更新 miniconda Python，不使用系统 Python
    print -P "%F{cyan}Step 2/4: Updating Miniconda%f"
    print -P "%F{white}NOTE: Only the base virtual environment will be updated.%f"
    conda activate base
    conda upgrade python --yes
    conda upgrade -n base --yes --all

    # (3) 更新 nvm 和 Node.js
    print -P "%F{cyan}Step 3/4: Updating NVM and Node.js%f"
    if command -v nvm >/dev/null 2>&1 || [[ -s "$NVM_DIR/nvm.sh" ]]; then
        # 确保 nvm 已加载
        [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

        # 更新 nvm 本身
        print -P "%F{yellow}> Updating nvm...%f"
        (
            cd "$NVM_DIR"
            git fetch --tags origin
            git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
        ) && source "$NVM_DIR/nvm.sh"

        # 获取当前使用的 Node 版本
        current_node=$(nvm current)
        print -P "%F{white}Current Node.js version: $current_node%f"

        # 更新到最新的 LTS 版本（如果当前使用的不是特定版本）
        if [[ $current_node != "system" ]] && [[ $current_node != "none" ]]; then
            # 获取最新 LTS 版本号
            latest_lts=$(nvm ls-remote --lts | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | tail -1)
            print -P "%F{white}Latest LTS version: $latest_lts%f"

            # 只有当前版本与最新 LTS 不同时才安装
            if [[ $current_node != $latest_lts ]]; then
                print -P "%F{yellow}> Installing latest LTS Node.js...%f"
                nvm install --lts
                nvm use --lts
            else
                print -P "%F{white}Already using latest LTS version, skipping installation%f"
            fi

            # 更新全局 npm
            print -P "%F{yellow}> Updating npm...%f"
            npm install -g npm@latest --no-fund

            # 可选：更新全局安装的 npm 包
            print -P "%F{yellow}> Updating global npm packages...%f"
            npm update -g --no-fund
        else
            print -P "%F{white}INFO: No active Node.js version detected, skipping Node.js update%f"
        fi
    else
        print -P "%F{white}INFO: nvm not detected, skipping NVM update%f"
    fi

    # (4) 更新系统包管理器下的软件
    case $os_type in
        macOS)
            print -P "%F{cyan}Step 4/4: Updating macOS Homebrew%f"
            brew update
            brew upgrade
            ;;
        Ubuntu)
            if command -v apt-get >/dev/null 2>&1; then
                print -P "%F{cyan}Step 4/4: Updating Ubuntu%f"

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
                print -P "%F{cyan}Step 4/4: Updating Debian%f"

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
                echo $fg[cyan]Step 4/4: Updating RedHat$reset_color
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
