function install_yazi() {

    # 1. Get the latest version number
    local YAZI_VERSION
    YAZI_VERSION=$(curl -s https://api.github.com/repos/sxyazi/yazi/tags | jq -r '.[].name' | sort -rV | head -n 1)

    # 2. Define related variables
    local CLEAN_YAZI_VERSION
    CLEAN_YAZI_VERSION=$(echo "$YAZI_VERSION" | sed 's/^v//')

    local YAZI_FOLDER="yazi-x86_64-unknown-linux-musl"
    local YAZI_COMPRESSED_FILE="${YAZI_FOLDER}.zip"
    local YAZI_DOWNLOAD_URL="https://github.com/sxyazi/yazi/releases/download/${YAZI_VERSION}/${YAZI_COMPRESSED_FILE}"

    # 3. Download and install the latest version
    echo "Downloading Yazi version ${YAZI_VERSION}..."
    wget -q "$YAZI_DOWNLOAD_URL" -O "/tmp/${YAZI_COMPRESSED_FILE}"

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to download yazi." >&2
        return 1
    fi

    echo "Extracting Yazi..."
    rm -fr "/tmp/${YAZI_FOLDER}" && pushd /tmp
    unzip "/tmp/${YAZI_COMPRESSED_FILE}" && popd

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to extract Yazi." >&2
        return 1
    fi

    echo "Installing Yazi..."
    sudo mv "/tmp/${YAZI_FOLDER}/yazi" "/usr/local/bin"
    sudo mv "/tmp/${YAZI_FOLDER}/ya" "/usr/local/bin"

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to move yazi binary." >&2
        return 1
    fi

    echo "Setting the owner and permissions of /usr/local/bin/yazi..."
    sudo chown root:root /usr/local/bin/yazi
    sudo chown root:root /usr/local/bin/ya
    sudo chmod 0755 /usr/local/bin/yazi
    sudo chmod 0755 /usr/local/bin/ya

    if [[ ! -x /usr/local/bin/yazi ]]; then
        echo "Error: /usr/local/bin/yazi is not executable. Check permissions." >&2
        return 1
    fi

    # 4. Clean up temporary files
    echo "Cleaning up..."
    rm "/tmp/${YAZI_COMPRESSED_FILE}"
    rm -fr "/tmp/${YAZI_FOLDER}"

    # 5. Verify installation
    echo "Verifying installation..."
    /usr/local/bin/yazi -V
    /usr/local/bin/ya -V

    if [[ $? -eq 0 ]]; then
        echo "Yazi installed successfully."
    else
        echo "Error: Yazi installation verification failed." >&2
        return 1
    fi
}
