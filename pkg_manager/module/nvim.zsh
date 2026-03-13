function install_nvim() {
    local INSTALL_DIR="${1:-/usr/local/bin}"
    local NVIM_VERSION="stable"
    local NVIM_APPIMAGE="nvim.appimage"
    local OS="linux"
    local ARCH=$(uname -m)
    local NVIM_DOWNLOAD_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-${OS}-${ARCH}.appimage"

    echo "Downloading Neovim (${NVIM_VERSION}) to ${INSTALL_DIR}..."
    mkdir -p "$INSTALL_DIR"
    if [[ "$INSTALL_DIR" == /usr/local/bin ]]; then
        sudo curl -Lo "${INSTALL_DIR}/${NVIM_APPIMAGE}" "$NVIM_DOWNLOAD_URL"
    else
        curl -Lo "${INSTALL_DIR}/${NVIM_APPIMAGE}" "$NVIM_DOWNLOAD_URL"
    fi

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to download Neovim." >&2
        return 1
    fi

    echo "Setting the owner and permissions of ${INSTALL_DIR}/${NVIM_APPIMAGE}..."
    if [[ "$INSTALL_DIR" == /usr/local/bin ]]; then
        sudo chown root:root "${INSTALL_DIR}/${NVIM_APPIMAGE}"
        sudo chmod 0755 "${INSTALL_DIR}/${NVIM_APPIMAGE}"
    else
        chmod 0755 "${INSTALL_DIR}/${NVIM_APPIMAGE}"
    fi

    if [[ ! -x "${INSTALL_DIR}/${NVIM_APPIMAGE}" ]]; then
        echo "Error: ${INSTALL_DIR}/${NVIM_APPIMAGE} is not executable. Check permissions." >&2
        return 1
    fi

    echo "Verifying installation..."
    "${INSTALL_DIR}/${NVIM_APPIMAGE}" --version

    if [[ $? -eq 0 ]]; then
        echo "Neovim installed successfully."
    else
        echo "Error: Neovim installation verification failed." >&2
        return 1
    fi
}
