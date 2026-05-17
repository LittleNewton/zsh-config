function _init_tmux_usage() {
    cat <<'EOF'
Usage: init-tmux [--force|-f]

Initialize the tmux layout for the current host by running:
  ${XDG_CONFIG_HOME:-$HOME/.config}/zsh/tmux/$(hostname -s).sh

Options:
  -f, --force    Ask for confirmation, then kill tmux session 'normal' before init
  -h, --help     Show this help message
EOF
}

function _init_tmux_hostname() {
    local host

    host=$(hostname -s 2>/dev/null)
    if [[ -z "$host" ]]; then
        host=$(hostname 2>/dev/null)
        host=${host%%.*}
    fi
    if [[ -z "$host" ]]; then
        host=${HOST%%.*}
    fi

    echo "$host"
}

function init-tmux() {
    local force=false
    local arg

    for arg in "$@"; do
        case "$arg" in
            -f|--force)
                force=true
                ;;
            -h|--help)
                _init_tmux_usage
                return 0
                ;;
            *)
                print -P "%F{red}ERROR: Unknown option: $arg%f"
                _init_tmux_usage
                return 2
                ;;
        esac
    done

    if ! command -v tmux >/dev/null 2>&1; then
        print -P "%F{red}ERROR: tmux not found in PATH.%f"
        return 1
    fi

    local host
    host=$(_init_tmux_hostname)
    if [[ -z "$host" ]]; then
        print -P "%F{red}ERROR: Unable to determine hostname.%f"
        return 1
    fi

    local zsh_config_home
    zsh_config_home="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
    if [[ -n "$ZDOTDIR" && -d "$ZDOTDIR/tmux" ]]; then
        zsh_config_home="$ZDOTDIR"
    fi

    local tmux_script
    tmux_script="$zsh_config_home/tmux/$host.sh"

    if [[ ! -f "$tmux_script" ]]; then
        print -P "%F{red}ERROR: tmux init script not found: $tmux_script%f"
        print -P "%F{white}Available scripts:%f"
        local available_script
        for available_script in "$zsh_config_home"/tmux/*.sh(N); do
            print "${available_script:t:r}"
        done
        return 1
    fi

    if [[ "$force" == true ]]; then
        local answer
        print -n "This will kill tmux session 'normal' before initializing '$host'. Continue? [y/N] "
        read -r answer
        case "$answer" in
            [yY])
                tmux kill-session -t normal 2>/dev/null || true
                ;;
            *)
                print "Aborted."
                return 130
                ;;
        esac
    fi

    "$tmux_script"
}

alias init_tmux='init-tmux'
