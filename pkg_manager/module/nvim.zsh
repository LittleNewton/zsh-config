function install_nvim() (
    local INSTALL_DIR="${1:-/usr/local/bin}"
    local NVIM_VERSION="stable"
    local NVIM_APPIMAGE="nvim.appimage"
    local OS="linux"
    local ARCH
    ARCH=$(_ltnt_asset_arch nvim) || return 1
    local NVIM_DOWNLOAD_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-${OS}-${ARCH}.appimage"

    local work_dir staging_dir=""
    local -a privilege=()
    if [[ "$INSTALL_DIR" == /usr/local/bin ]]; then
        privilege=(sudo)
    fi
    work_dir=$(mktemp -d "${TMPDIR:-/tmp}/ltnt-nvim.XXXXXXXX") || return 1
    trap 'rm -rf -- "$work_dir"; if [[ -n "$staging_dir" ]]; then "${privilege[@]}" rm -rf -- "$staging_dir"; fi' EXIT
    trap 'exit 1' HUP INT TERM

    echo "Downloading Neovim (${NVIM_VERSION})..."
    if ! curl -fsSL "$NVIM_DOWNLOAD_URL" -o "$work_dir/$NVIM_APPIMAGE"; then
        echo "Error: Failed to download Neovim." >&2
        return 1
    fi

    chmod 0755 "$work_dir/$NVIM_APPIMAGE" || return $?
    echo "Verifying downloaded Neovim..."
    if ! APPIMAGE_EXTRACT_AND_RUN=1 "$work_dir/$NVIM_APPIMAGE" --version; then
        echo "Error: Neovim verification failed; the existing installation was not changed." >&2
        return 1
    fi

    # Provide the nvim command used by EDITOR, without requiring FUSE.
    cat > "$work_dir/nvim" <<'EOF'
#!/bin/sh
install_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd) || exit 1
export APPIMAGE_EXTRACT_AND_RUN=1
exec "$install_dir/nvim.appimage" "$@"
EOF
    if [[ $? -ne 0 ]]; then
        return 1
    fi

    echo "Installing Neovim to ${INSTALL_DIR}..."
    "${privilege[@]}" mkdir -p -- "$INSTALL_DIR" || return $?
    # Stage on the destination filesystem so each final rename is atomic.
    staging_dir=$("${privilege[@]}" mktemp -d "$INSTALL_DIR/.ltnt-nvim.XXXXXXXX") || return 1
    "${privilege[@]}" install -m 0755 "$work_dir/$NVIM_APPIMAGE" "$work_dir/nvim" "$staging_dir/" || return $?
    "${privilege[@]}" mv -fT -- "$staging_dir/$NVIM_APPIMAGE" "$INSTALL_DIR/$NVIM_APPIMAGE" || return $?
    "${privilege[@]}" mv -fT -- "$staging_dir/nvim" "$INSTALL_DIR/nvim" || return $?
    if ! "$INSTALL_DIR/nvim" --version; then
        echo "Error: Installed nvim command failed verification." >&2
        return 1
    fi
    echo "Neovim installed successfully."
)
