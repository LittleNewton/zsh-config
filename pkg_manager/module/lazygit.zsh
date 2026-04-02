function install_lazygit() {
    local INSTALL_DIR="${1:-/usr/local/bin}"

    # 检查依赖
    if ! command -v jq &>/dev/null; then
        echo "Error: 'jq' is required but not installed." >&2
        return 1
    fi

    local LAZYGIT_ARCH
    LAZYGIT_ARCH=$(_ltnt_asset_arch lazygit) || return 1

    # 1. 获取最新版本号
    local LAZYGIT_RELEASE
    LAZYGIT_RELEASE=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest)
    if [[ $? -ne 0 || -z "$LAZYGIT_RELEASE" ]]; then
        echo "Error: Failed to fetch Lazygit release metadata." >&2
        return 1
    fi

    local LAZYGIT_VERSION
    LAZYGIT_VERSION=$(printf '%s' "$LAZYGIT_RELEASE" | jq -r '.tag_name')
    if [[ -z "$LAZYGIT_VERSION" || "$LAZYGIT_VERSION" == "null" ]]; then
        echo "Error: Failed to resolve the latest Lazygit version." >&2
        return 1
    fi

    # 2. 定义相关变量
    local LAZYGIT_COMPRESSED_FILE
    LAZYGIT_COMPRESSED_FILE=$(printf '%s' "$LAZYGIT_RELEASE" | jq -r --arg arch "$LAZYGIT_ARCH" '.assets[] | select(.name | ascii_downcase | endswith("linux_" + $arch + ".tar.gz")) | .name' | head -n 1)
    if [[ -z "$LAZYGIT_COMPRESSED_FILE" ]]; then
        echo "Error: No Lazygit binary was found for architecture '${LAZYGIT_ARCH}'." >&2
        return 1
    fi

    local LAZYGIT_FOLDER="${LAZYGIT_COMPRESSED_FILE%.tar.gz}"
    local LAZYGIT_DOWNLOAD_URL
    LAZYGIT_DOWNLOAD_URL=$(printf '%s' "$LAZYGIT_RELEASE" | jq -r --arg name "$LAZYGIT_COMPRESSED_FILE" '.assets[] | select(.name == $name) | .browser_download_url' | head -n 1)
    if [[ -z "$LAZYGIT_DOWNLOAD_URL" || "$LAZYGIT_DOWNLOAD_URL" == "null" ]]; then
        echo "Error: Failed to resolve the Lazygit download URL." >&2
        return 1
    fi

    # 3. 下载并安装最新版本
    echo "Downloading Lazygit version ${LAZYGIT_VERSION}..."
    curl -fsSL "$LAZYGIT_DOWNLOAD_URL" -o "/tmp/${LAZYGIT_COMPRESSED_FILE}"

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to download lazygit." >&2
        return 1
    fi

    echo "Extracting Lazygit..."
    rm -fr "/tmp/${LAZYGIT_FOLDER}" && mkdir -p "/tmp/${LAZYGIT_FOLDER}"
    tar -C "/tmp/${LAZYGIT_FOLDER}" -xzf "/tmp/${LAZYGIT_COMPRESSED_FILE}"

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to extract Lazygit." >&2
        return 1
    fi

    echo "Installing Lazygit to ${INSTALL_DIR}..."
    mkdir -p "$INSTALL_DIR"
    if [[ "$INSTALL_DIR" == /usr/local/bin ]]; then
        sudo mv "/tmp/${LAZYGIT_FOLDER}/lazygit" "${INSTALL_DIR}"
        sudo chown root:root "${INSTALL_DIR}/lazygit"
        sudo chmod 0755 "${INSTALL_DIR}/lazygit"
    else
        mv "/tmp/${LAZYGIT_FOLDER}/lazygit" "${INSTALL_DIR}"
        chmod 0755 "${INSTALL_DIR}/lazygit"
    fi

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to move lazygit binary." >&2
        return 1
    fi

    if [[ ! -x "${INSTALL_DIR}/lazygit" ]]; then
        echo "Error: ${INSTALL_DIR}/lazygit is not executable. Check permissions." >&2
        return 1
    fi

    # 4. 清理临时文件
    echo "Cleaning up..."
    rm "/tmp/${LAZYGIT_COMPRESSED_FILE}"
    rm -fr "/tmp/${LAZYGIT_FOLDER}"

    # 5. 验证安装
    echo "Verifying installation..."
    "${INSTALL_DIR}/lazygit" -v

    if [[ $? -eq 0 ]]; then
        echo "Lazygit installed successfully."
    else
        echo "Error: Lazygit installation verification failed." >&2
        return 1
    fi
}
