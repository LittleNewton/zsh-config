function _ltnt_normalize_linux_arch() {
    local arch="${1:-$(uname -m)}"

    case "$arch" in
    x86_64|amd64)
        echo "x86_64"
        ;;
    aarch64|arm64)
        echo "aarch64"
        ;;
    *)
        echo "Error: Unsupported architecture '$arch'." >&2
        return 1
        ;;
    esac
}

function _ltnt_asset_arch() {
    local package=$1
    local normalized_arch

    normalized_arch=$(_ltnt_normalize_linux_arch "${2:-$(uname -m)}") || return 1

    case "$package" in
    joshuto|yazi)
        echo "$normalized_arch"
        ;;
    lazygit|nvim)
        case "$normalized_arch" in
        x86_64) echo "x86_64" ;;
        aarch64) echo "arm64" ;;
        esac
        ;;
    *)
        echo "Error: Unsupported package '$package'." >&2
        return 1
        ;;
    esac
}

function _ltnt_detect_linux_libc() {
    local musl_loaders=(/lib/ld-musl-*.so.1(N) /usr/lib/ld-musl-*.so.1(N))

    if command -v ldd >/dev/null 2>&1 && ldd --version 2>&1 | grep -qi "musl"; then
        echo "musl"
    elif (( ${#musl_loaders[@]} > 0 )); then
        echo "musl"
    else
        echo "gnu"
    fi
}

function _ltnt_brew_formula() {
    case "$1" in
    joshuto|lazygit|yazi)
        echo "$1"
        ;;
    neovim|nvim)
        echo "neovim"
        ;;
    *)
        echo "Error: Unsupported package '$1'." >&2
        return 1
        ;;
    esac
}

function _ltnt_install_with_brew() {
    local package=$1
    local dest=$2
    local formulas=()

    if ! command -v brew >/dev/null 2>&1; then
        echo "Error: Homebrew is required on macOS, but 'brew' was not found." >&2
        return 1
    fi

    if [[ "$dest" != "system" ]]; then
        echo "Info: --dest '$dest' is ignored on macOS because Homebrew manages installation paths."
    fi

    case "$package" in
    all)
        formulas=(joshuto lazygit neovim yazi)
        ;;
    *)
        formulas=("$(_ltnt_brew_formula "$package")") || return 1
        ;;
    esac

    brew install "${formulas[@]}"
}

function ltnt_install() {

    # Check if os_type is defined
    if [[ -z "$os_type" ]]; then
        echo "Error: os_type is not defined. Please set it before running this script." >&2
        return 1
    fi
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
            if [[ -z "$2" ]]; then
                echo "Error: Missing value for --dest. Use 'system' or 'user'." >&2
                return 1
            fi
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

    # Get the directory of the current script
    local script_path="${(%):-%x}"
    local module_dir="${script_path:A:h}/module"

    case $package in
    joshuto|lazygit|yazi)
        ;;
    neovim)
        ;;
    all)
        ;;
    *)
        echo "Error: Unsupported package '$package'." >&2
        return 1
        ;;
    esac

    if [[ $os_type == "macOS" ]]; then
        _ltnt_install_with_brew "$package" "$dest"
        return $?
    fi

    if [[ $os_type == "Debian" || $os_type == "Ubuntu" || $os_type == "TrueNAS_SCALE" ]]; then
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
        echo "Error: Unsupported OS type '$os_type'. This script supports macOS, Debian, Ubuntu, and TrueNAS SCALE." >&2
        return 1
    fi
}
