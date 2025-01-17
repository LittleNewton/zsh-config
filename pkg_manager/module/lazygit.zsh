function install_lazygit() {
    # 1. 获取最新版本号
    local LAZYGIT_VERSION
    LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/tags | jq -r '.[].name' | sort -rV | head -n 1)

    # 2. 定义相关变量
    local CLEAN_LAZYGIT_VERSION
    CLEAN_LAZYGIT_VERSION=$(echo "$LAZYGIT_VERSION" | sed 's/^v//')

    local LAZYGIT_FOLDER="lazygit_${CLEAN_LAZYGIT_VERSION}_Linux_x86_64"
    local LAZYGIT_COMPRESSED_FILE="${LAZYGIT_FOLDER}.tar.gz"
    local LAZYGIT_DOWNLOAD_URL="https://github.com/jesseduffield/lazygit/releases/download/${LAZYGIT_VERSION}/${LAZYGIT_COMPRESSED_FILE}"

    # 3. 下载并安装最新版本
    echo "Downloading Lazygit version ${LAZYGIT_VERSION}..."
    wget -q "$LAZYGIT_DOWNLOAD_URL" -O "/tmp/${LAZYGIT_COMPRESSED_FILE}"

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

    echo "Installing Lazygit..."
    sudo mv "/tmp/${LAZYGIT_FOLDER}/lazygit" "/usr/local/bin"

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to move lazygit binary." >&2
        return 1
    fi

    # 4. 清理临时文件
    echo "Cleaning up..."
    rm "/tmp/${LAZYGIT_COMPRESSED_FILE}"
    rm -fr "/tmp/${LAZYGIT_FOLDER}"

    # 5. 验证安装
    echo "Verifying installation..."
    /usr/local/bin/lazygit -v

    if [[ $? -eq 0 ]]; then
        echo "Lazygit installed successfully."
    else
        echo "Error: Lazygit installation verification failed." >&2
        return 1
    fi
}
