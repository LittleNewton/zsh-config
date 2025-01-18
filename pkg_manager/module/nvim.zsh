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

    echo "Setting the owner and permissions of /usr/local/bin/${NVIM_APPIMAGE}..."
    sudo chown root:root /usr/local/bin/${NVIM_APPIMAGE}
    sudo chmod 0755 /usr/local/bin/${NVIM_APPIMAGE}

    if [[ ! -x /usr/local/bin/${NVIM_APPIMAGE} ]]; then
        echo "Error: /usr/local/bin/${NVIM_APPIMAGE} is not executable. Check permissions." >&2
        return 1
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
