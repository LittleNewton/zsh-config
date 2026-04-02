function install_yazi() {
    local INSTALL_DIR="${1:-/usr/local/bin}"

    # 检查依赖
    if ! command -v jq &>/dev/null; then
        echo "Error: 'jq' is required but not installed." >&2
        return 1
    fi

    local YAZI_ARCH
    YAZI_ARCH=$(_ltnt_asset_arch yazi) || return 1

    local YAZI_LIBC
    YAZI_LIBC=$(_ltnt_detect_linux_libc)

    local YAZI_LIBC_FALLBACK="musl"
    if [[ "$YAZI_LIBC" == "musl" ]]; then
        YAZI_LIBC_FALLBACK="gnu"
    fi

    # 1. Get the latest version number
    local YAZI_RELEASE
    YAZI_RELEASE=$(curl -fsSL https://api.github.com/repos/sxyazi/yazi/releases/latest)
    if [[ $? -ne 0 || -z "$YAZI_RELEASE" ]]; then
        echo "Error: Failed to fetch Yazi release metadata." >&2
        return 1
    fi

    local YAZI_VERSION
    YAZI_VERSION=$(printf '%s' "$YAZI_RELEASE" | jq -r '.tag_name')
    if [[ -z "$YAZI_VERSION" || "$YAZI_VERSION" == "null" ]]; then
        echo "Error: Failed to resolve the latest Yazi version." >&2
        return 1
    fi

    # 2. Define related variables
    local candidate_libc
    local YAZI_FOLDER=""
    local YAZI_COMPRESSED_FILE=""
    local YAZI_DOWNLOAD_URL=""

    for candidate_libc in "$YAZI_LIBC" "$YAZI_LIBC_FALLBACK"; do
        YAZI_COMPRESSED_FILE=$(printf '%s' "$YAZI_RELEASE" | jq -r --arg arch "$YAZI_ARCH" --arg libc "$candidate_libc" '.assets[] | select(.name == ("yazi-" + $arch + "-unknown-linux-" + $libc + ".zip")) | .name' | head -n 1)

        if [[ -n "$YAZI_COMPRESSED_FILE" ]]; then
            YAZI_FOLDER="${YAZI_COMPRESSED_FILE%.zip}"
            YAZI_DOWNLOAD_URL=$(printf '%s' "$YAZI_RELEASE" | jq -r --arg name "$YAZI_COMPRESSED_FILE" '.assets[] | select(.name == $name) | .browser_download_url' | head -n 1)
            break
        fi
    done

    if [[ -z "$YAZI_COMPRESSED_FILE" || -z "$YAZI_DOWNLOAD_URL" ]]; then
        echo "Error: No Yazi binary was found for architecture '${YAZI_ARCH}'." >&2
        return 1
    fi

    # 3. Download and install the latest version
    echo "Downloading Yazi version ${YAZI_VERSION}..."
    curl -fsSL "$YAZI_DOWNLOAD_URL" -o "/tmp/${YAZI_COMPRESSED_FILE}"

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
