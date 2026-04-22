export IS_TEXLIVE_INSTALLED="false"

# Map (kernel, arch) to the TeX Live binary sub-directory name.
# Ref: https://tug.org/texlive/doc/texlive-en/texlive-en.html
_texlive_bin_dir() {
    case "$(uname -s):$(uname -m)" in
        Darwin:*)                  echo "universal-darwin" ;;   # TL 2022+ ships a universal fat binary
        Linux:x86_64|Linux:amd64)  echo "x86_64-linux" ;;
        Linux:aarch64|Linux:arm64) echo "aarch64-linux" ;;
        Linux:i?86)                echo "i386-linux" ;;
        Linux:armv7l|Linux:armv6l) echo "armhf-linux" ;;
        FreeBSD:amd64)             echo "amd64-freebsd" ;;
        FreeBSD:i?86)              echo "i386-freebsd" ;;
        *) return 1 ;;
    esac
}

_set_texlive() {
    local texlive_folder="/usr/local/texlive"
    [[ -d "$texlive_folder" ]] || return 0

    local max_version
    max_version=$(
        find "$texlive_folder" -mindepth 1 -maxdepth 1 -type d 2>/dev/null \
            | while read -r d; do basename "$d"; done \
            | grep -E '^20[0-9]{2}$' \
            | sort -r \
            | head -n1
    )
    [[ -n "$max_version" ]] || return 0

    local bin_dir
    if ! bin_dir=$(_texlive_bin_dir); then
        echo "WARN: TeX Live found at $texlive_folder/$max_version but platform is unsupported: $(uname -sm)." >&2
        return 1
    fi

    local bin_path="$texlive_folder/$max_version/bin/$bin_dir"
    if [[ ! -d "$bin_path" ]]; then
        echo "WARN: TeX Live $max_version: expected binary dir $bin_path not found." >&2
        return 1
    fi

    export IS_TEXLIVE_INSTALLED="true"
    export MANPATH="$texlive_folder/$max_version/texmf-dist/doc/man:$MANPATH"
    export INFOPATH="$texlive_folder/$max_version/texmf-dist/doc/info:$INFOPATH"
    export PATH="$bin_path:$PATH"
}

_set_texlive
