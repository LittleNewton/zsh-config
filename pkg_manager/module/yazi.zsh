function install_yazi() {
    local INSTALL_DIR="${1:-/usr/local/bin}"

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

    echo "Installing Yazi to ${INSTALL_DIR}..."
    mkdir -p "$INSTALL_DIR"
    if [[ "$INSTALL_DIR" == /usr/local/bin ]]; then
        sudo mv "/tmp/${YAZI_FOLDER}/yazi" "${INSTALL_DIR}"
        sudo mv "/tmp/${YAZI_FOLDER}/ya" "${INSTALL_DIR}"
        sudo chown root:root "${INSTALL_DIR}/yazi" "${INSTALL_DIR}/ya"
        sudo chmod 0755 "${INSTALL_DIR}/yazi" "${INSTALL_DIR}/ya"
    else
        mv "/tmp/${YAZI_FOLDER}/yazi" "${INSTALL_DIR}"
        mv "/tmp/${YAZI_FOLDER}/ya" "${INSTALL_DIR}"
        chmod 0755 "${INSTALL_DIR}/yazi" "${INSTALL_DIR}/ya"
    fi

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to move yazi binary." >&2
        return 1
    fi

    if [[ ! -x "${INSTALL_DIR}/yazi" ]]; then
        echo "Error: ${INSTALL_DIR}/yazi is not executable. Check permissions." >&2
        return 1
    fi

    # 4. Clean up temporary files
    echo "Cleaning up..."
    rm "/tmp/${YAZI_COMPRESSED_FILE}"
    rm -fr "/tmp/${YAZI_FOLDER}"

    # 5. Verify installation
    echo "Verifying installation..."
    "${INSTALL_DIR}/yazi" -V
    "${INSTALL_DIR}/ya" -V

    if [[ $? -eq 0 ]]; then
        echo "Yazi installed successfully."
    else
        echo "Error: Yazi installation verification failed." >&2
        return 1
    fi
}
