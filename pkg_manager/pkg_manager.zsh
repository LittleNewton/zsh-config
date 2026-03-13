function ltnt_install() {

    # Check if os_type is defined
    if [[ -z "$os_type" ]]; then
        echo "Error: os_type is not defined. Please set it before running this script." >&2
        return 1
    fi
    # Get the directory of the current script
    local module_dir=$(dirname $(realpath ${(%):-%x}))/module

    if [[ $os_type == "Debian" || $os_type == "TrueNAS_SCALE" ]]; then
        if [[ $# -eq 0 ]]; then
            echo "Error: No package specified. Usage: ltnt_install <package_name> [--dest system|user]" >&2
            return 1
        fi

        local package=$1
        shift

        # Parse --dest option
        local dest="system"
        while [[ $# -gt 0 ]]; do
            case $1 in
            --dest)
                dest="$2"
                shift 2
                ;;
            *)
                echo "Error: Unknown option '$1'." >&2
                return 1
                ;;
            esac
        done

        local install_dir
        case $dest in
        system) install_dir="/usr/local/bin" ;;
        user)   install_dir="${HOME}/.local/bin" ;;
        *)
            echo "Error: Invalid --dest value '$dest'. Use 'system' or 'user'." >&2
            return 1
            ;;
        esac

        _ltnt_run_install() {
            local pkg=$1
            local script="${module_dir}/${pkg}.zsh"
            local fn="install_${pkg}"
            if [[ -f "$script" ]]; then
                source "$script"
                if typeset -f "$fn" > /dev/null 2>&1; then
                    $fn "$install_dir"
                else
                    echo "Warning: Install function $fn not found in $script." >&2
                fi
            else
                echo "Error: $pkg installation script not found in ${script}" >&2
                return 1
            fi
        }

        case $package in
        joshuto|lazygit|neovim|yazi)
            local script_name=$package
            [[ $package == "neovim" ]] && script_name="nvim"
            _ltnt_run_install "$script_name"
            ;;
        all)
            echo "Installing all available packages to ${install_dir}..."
            for script in ${module_dir}/*.zsh; do
                if [[ -f "$script" ]]; then
                    local script_name=$(basename "$script" .zsh)
                    echo "Installing ${script_name}..."
                    _ltnt_run_install "$script_name"
                fi
            done
            ;;
        *)
            echo "Error: Unsupported package '$package'." >&2
            unfunction _ltnt_run_install
            return 1
            ;;
        esac

        unfunction _ltnt_run_install
    else
        echo "Error: Unsupported OS type '$os_type'. This script only supports Debian or TrueNAS SCALE." >&2
        return 1
    fi
}
