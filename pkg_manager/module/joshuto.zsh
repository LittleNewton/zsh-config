function install_joshuto() {
    # 1. 获取最新版本号
    local JOSHUTO_VERSION
    JOSHUTO_VERSION=$(curl -s https://api.github.com/repos/kamiyaa/joshuto/tags | jq -r '.[].name' | sort -rV | head -n 1)

    # 2. 定义相关变量
    local JOSHUTO_FOLDER="joshuto-${JOSHUTO_VERSION}-x86_64-unknown-linux-musl"
    local JOSHUTO_DOWNLOAD_URL="https://github.com/kamiyaa/joshuto/releases/download/${JOSHUTO_VERSION}/${JOSHUTO_FOLDER}.tar.gz"
    local JOSHUTO_COMPRESSED_FILE="${JOSHUTO_FOLDER}.tar.gz"

    # 3. 下载并安装最新版本
    echo "Downloading Joshuto version ${JOSHUTO_VERSION}..."
    wget -q "$JOSHUTO_DOWNLOAD_URL" -O "/tmp/$JOSHUTO_COMPRESSED_FILE"

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to download Joshuto." >&2
        return 1
    fi

    echo "Extracting Joshuto..."
    tar -C "/tmp" -xzf "/tmp/${JOSHUTO_COMPRESSED_FILE}"

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to extract Joshuto." >&2
        return 1
    fi

    echo "Installing Joshuto..."
    sudo mv "/tmp/${JOSHUTO_FOLDER}/joshuto" /usr/local/bin

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to move Joshuto binary." >&2
        return 1
    fi

    # 4. 清理临时文件
    echo "Cleaning up..."
    rm "/tmp/${JOSHUTO_COMPRESSED_FILE}"
    rm -fr "/tmp/${JOSHUTO_FOLDER}"

    # 5. 验证安装
    echo "Verifying installation..."
    /usr/local/bin/joshuto version

    if [[ $? -eq 0 ]]; then
        echo "Joshuto installed successfully."
    else
        echo "Error: Joshuto installation verification failed." >&2
        return 1
    fi
}
