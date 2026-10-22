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
    micromamba activate "$DEFAULT_MAMBA_ENV" || return $?
    micromamba update --all --yes -n "$DEFAULT_MAMBA_ENV" || return $?
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
    if [[ -s "$NVM_DIR/nvm.sh" ]]; then
        source "$NVM_DIR/nvm.sh" || return $?
    fi

    # Update nvm itself via git
    print -P "%F{yellow}> Updating nvm via git...%f"
    (
        cd "$NVM_DIR" || return $?
        git fetch --tags origin || return $?
        local latest_commit latest_tag
        latest_commit=$(git rev-list --tags --max-count=1) || return $?
        [[ -n "$latest_commit" ]] || return 1
        latest_tag=$(git describe --abbrev=0 --tags --match "v[0-9]*" "$latest_commit") || return $?
        git checkout "$latest_tag"
    ) || return $?
    source "$NVM_DIR/nvm.sh" || return $?

    local current_node current_result=0
    current_node=$(nvm current) || current_result=$?
    print -P "%F{white}Current Node.js version: ${current_node}%f"

    if [[ $current_node == "system" ]] || [[ $current_node == "none" ]]; then
        print -P "%F{white}INFO: No active nvm-managed Node.js, skipping Node.js update.%f"
        return 0
    fi
    (( current_result == 0 )) || return "$current_result"

    # Check if already on latest LTS
    local versions latest_lts
    versions=$(nvm ls-remote --lts) || return $?
    latest_lts=$(print -r -- "$versions" | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | tail -1)
    if [[ -z "$latest_lts" ]]; then
        print -u2 -- "ERROR: Unable to determine the latest Node.js LTS version."
        return 1
    fi
    print -P "%F{white}Latest LTS version: ${latest_lts}%f"

    if [[ $current_node != $latest_lts ]]; then
        print -P "%F{yellow}> Installing latest LTS Node.js...%f"
        nvm install --lts || return $?
        nvm use --lts || return $?
    else
        print -P "%F{white}Already on latest LTS, skipping installation.%f"
    fi

    print -P "%F{yellow}> Updating npm...%f"
    npm install -g npm@latest --no-fund || return $?

    print -P "%F{yellow}> Updating global npm packages...%f"
    npm update -g --no-fund
}

function _os_update_os_packages() {
    local step=$1
    print -P "%F{cyan}Step ${step}: OS package manager ($os_type)%f"
    case $os_type in
        macOS)
            brew update || return $?
            brew outdated || return $?
            brew upgrade || return $?
            brew cleanup || return $?
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
                eval "$cmd" || return $?
            done
            ;;
        RedHat)
            if ! command -v yum >/dev/null 2>&1; then
                print -P "%F{red}ERROR: yum not found on RedHat system.%f"
                return 1
            fi
            sudo yum update -y || return $?
            sudo yum autoremove -y || return $?
            sudo yum clean all
            ;;
        *)
            print -P "%F{red}ERROR: Unsupported OS type: $os_type.%f"
            return 1
            ;;
    esac
}

function os-update() {
    local step step_result
    local -a steps=(
        _os_update_texlive
        _os_update_micromamba
        _os_update_nvm
        _os_update_os_packages
    )
    local -a labels=("TeX Live" "micromamba" "NVM/Node.js" "OS packages")
    local -a failed_steps=()
    for (( step=1; step <= ${#steps}; step++ )); do
        if "${steps[$step]}" "$step"; then
            continue
        else
            step_result=$?
            failed_steps+=("${labels[$step]} (exit $step_result)")
        fi
    done
    if (( ${#failed_steps} )); then
        print -u2 -r -- "Failed update stages: ${(j:, :)failed_steps}"
        return 1
    fi
    return 0
}
