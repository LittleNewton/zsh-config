function install_nvim() {
    local NVIM_VERSION="stable"
    local NVIM_APPIMAGE="nvim.appimage"
    local NVIM_DOWNLOAD_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${NVIM_APPIMAGE}"

    echo "Downloading Neovim (${NVIM_VERSION}) directly to /usr/local/bin..."
    sudo curl -Lo /usr/local/bin/${NVIM_APPIMAGE} "$NVIM_DOWNLOAD_URL"

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to download Neovim." >&2
        return 1
    fi

    echo "Checking and setting executable permissions for /usr/local/bin/${NVIM_APPIMAGE}..."
    if [[ ! -x /usr/local/bin/${NVIM_APPIMAGE} ]]; then
        sudo chmod u+x /usr/local/bin/${NVIM_APPIMAGE}
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to set executable permissions for /usr/local/bin/${NVIM_APPIMAGE}." >&2
            return 1
        fi
    else
        echo "Permissions are already set correctly for /usr/local/bin/${NVIM_APPIMAGE}."
    fi

    echo "Verifying installation..."
    /usr/local/bin/nvim.appimage --version

    if [[ $? -eq 0 ]]; then
        echo "Neovim installed successfully."
    else
        echo "Error: Neovim installation verification failed." >&2
        return 1
    fi
}
