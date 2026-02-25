export IS_TEXLIVE_INSTALLED="false"

function _set_texlive() {
    local texlive_folder="/usr/local/texlive"

    if [[ -d "$texlive_folder" ]]; then
        local MAX_TEXLIVE_VERSION
        MAX_TEXLIVE_VERSION=$(
            find "$texlive_folder" -mindepth 1 -maxdepth 1 -type d | while read -r d; do basename "$d"; done | grep -E '^20[0-9]{2}$' | sort -r | head -n1
        )

        if [[ -n "$MAX_TEXLIVE_VERSION" ]]; then
            IS_TEXLIVE_INSTALLED="true"

            local BIN_DIR=""
            case "$os_type" in
                macOS)  BIN_DIR="universal-darwin" ;;
                Debian) BIN_DIR="x86_64-linux" ;;
                *) echo "系统类型无法识别: $os_type"; return 1 ;;
            esac

            export MANPATH="$texlive_folder/$MAX_TEXLIVE_VERSION/texmf-dist/doc/man:$MANPATH"
            export INFOPATH="$texlive_folder/$MAX_TEXLIVE_VERSION/texmf-dist/doc/info:$INFOPATH"
            export PATH="$texlive_folder/$MAX_TEXLIVE_VERSION/bin/$BIN_DIR:$PATH"
        fi
    fi
}

_set_texlive
