function _os_update_texlive() {
    local step=$1
    print -P "%F{cyan}Step ${step}: TeX Live (tlmgr)%f"
    if [[ $IS_TEXLIVE_INSTALLED == "true" ]]; then
        sudo tlmgr update --self --all
    else
        print -P "%F{white}INFO: TeX Live not detected, skipping.%f"
    fi
}

function _os_update_micromamba() {
    local step=$1
    print -P "%F{cyan}Step ${step}: micromamba (${DEFAULT_MAMBA_ENV} environment)%f"
    if ! command -v micromamba >/dev/null 2>&1; then
        print -P "%F{white}INFO: micromamba not found, skipping.%f"
        return 0
    fi
    print -P "%F{white}NOTE: Only the ${DEFAULT_MAMBA_ENV} virtual environment will be updated.%f"
    micromamba activate ${DEFAULT_MAMBA_ENV}
    micromamba update --all --yes -n ${DEFAULT_MAMBA_ENV}
    micromamba clean --all --yes
}

function _os_update_nvm() {
    local step=$1
    print -P "%F{cyan}Step ${step}: NVM and Node.js%f"
    if ! command -v nvm >/dev/null 2>&1 && [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
        print -P "%F{white}INFO: nvm not detected, skipping.%f"
        return 0
    fi

    # Ensure nvm is loaded
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"

    # Update nvm itself via git
    print -P "%F{yellow}> Updating nvm via git...%f"
    (
        cd "$NVM_DIR"
        git fetch --tags origin
        git checkout $(git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1))
    ) && source "$NVM_DIR/nvm.sh"

    local current_node
    current_node=$(nvm current)
    print -P "%F{white}Current Node.js version: ${current_node}%f"

    if [[ $current_node == "system" ]] || [[ $current_node == "none" ]]; then
        print -P "%F{white}INFO: No active nvm-managed Node.js, skipping Node.js update.%f"
        return 0
    fi

    # Check if already on latest LTS
    local latest_lts
    latest_lts=$(nvm ls-remote --lts | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | tail -1)
    print -P "%F{white}Latest LTS version: ${latest_lts}%f"

    if [[ $current_node != $latest_lts ]]; then
        print -P "%F{yellow}> Installing latest LTS Node.js...%f"
        nvm install --lts
        nvm use --lts
    else
        print -P "%F{white}Already on latest LTS, skipping installation.%f"
    fi

    print -P "%F{yellow}> Updating npm...%f"
    npm install -g npm@latest --no-fund

    print -P "%F{yellow}> Updating global npm packages...%f"
    npm update -g --no-fund
}

function _os_update_os_packages() {
    local step=$1
    print -P "%F{cyan}Step ${step}: OS package manager ($os_type)%f"
    case $os_type in
        macOS)
            brew update
            brew outdated
            brew upgrade
            brew cleanup
            brew autoremove
            ;;
        Ubuntu|Debian)
            if ! command -v apt-get >/dev/null 2>&1; then
                print -P "%F{red}ERROR: apt-get not found on $os_type system.%f"
                return 1
            fi
            local cmds=(
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
            ;;
        RedHat)
            if ! command -v yum >/dev/null 2>&1; then
                print -P "%F{red}ERROR: yum not found on RedHat system.%f"
                return 1
            fi
            sudo yum update -y
            sudo yum autoremove -y
            sudo yum clean all
            ;;
        *)
            print -P "%F{red}ERROR: Unsupported OS type: $os_type.%f"
            return 1
            ;;
    esac
}

function os-update() {
    local step=0
    (( step++ )) ; _os_update_texlive      $step
    (( step++ )) ; _os_update_micromamba   $step
    (( step++ )) ; _os_update_nvm          $step
    (( step++ )) ; _os_update_os_packages  $step
}
