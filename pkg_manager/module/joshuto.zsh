function install_joshuto() {
    local INSTALL_DIR="${1:-/usr/local/bin}"

    if ! command -v jq &>/dev/null; then
        echo "Error: 'jq' is required but not installed." >&2
        return 1
    fi

    local JOSHUTO_ARCH
    JOSHUTO_ARCH=$(_ltnt_asset_arch joshuto) || return 1

    local JOSHUTO_LIBC
    JOSHUTO_LIBC=$(_ltnt_detect_linux_libc)

    local JOSHUTO_LIBC_FALLBACK="musl"
    if [[ "$JOSHUTO_LIBC" == "musl" ]]; then
        JOSHUTO_LIBC_FALLBACK="gnu"
    fi

    # 1. 获取最新版本号
    local JOSHUTO_RELEASE
    JOSHUTO_RELEASE=$(curl -fsSL "https://api.github.com/repos/kamiyaa/joshuto/releases?per_page=1")
    if [[ $? -ne 0 || -z "$JOSHUTO_RELEASE" ]]; then
        echo "Error: Failed to fetch Joshuto release metadata." >&2
        return 1
    fi

    local JOSHUTO_VERSION
    JOSHUTO_VERSION=$(printf '%s' "$JOSHUTO_RELEASE" | jq -r '.[0].tag_name')
    if [[ -z "$JOSHUTO_VERSION" || "$JOSHUTO_VERSION" == "null" ]]; then
        echo "Error: Failed to resolve the latest Joshuto version." >&2
        return 1
    fi

    # 2. 定义相关变量
    local candidate_libc
    local JOSHUTO_FOLDER=""
    local JOSHUTO_DOWNLOAD_URL=""
    local JOSHUTO_COMPRESSED_FILE=""

    for candidate_libc in "$JOSHUTO_LIBC" "$JOSHUTO_LIBC_FALLBACK"; do
        JOSHUTO_COMPRESSED_FILE=$(printf '%s' "$JOSHUTO_RELEASE" | jq -r --arg version "$JOSHUTO_VERSION" --arg arch "$JOSHUTO_ARCH" --arg libc "$candidate_libc" '.[0].assets[] | select(.name == ("joshuto-" + $version + "-" + $arch + "-unknown-linux-" + $libc + ".tar.gz")) | .name' | head -n 1)

        if [[ -n "$JOSHUTO_COMPRESSED_FILE" ]]; then
            JOSHUTO_FOLDER="${JOSHUTO_COMPRESSED_FILE%.tar.gz}"
            JOSHUTO_DOWNLOAD_URL=$(printf '%s' "$JOSHUTO_RELEASE" | jq -r --arg name "$JOSHUTO_COMPRESSED_FILE" '.[0].assets[] | select(.name == $name) | .browser_download_url' | head -n 1)
            break
        fi
    done

    if [[ -z "$JOSHUTO_COMPRESSED_FILE" || -z "$JOSHUTO_DOWNLOAD_URL" ]]; then
        echo "Error: No Joshuto binary was found for architecture '${JOSHUTO_ARCH}'." >&2
        return 1
    fi

    # 3. 下载并安装最新版本
    echo "Downloading Joshuto version ${JOSHUTO_VERSION}..."
    curl -fsSL "$JOSHUTO_DOWNLOAD_URL" -o "/tmp/$JOSHUTO_COMPRESSED_FILE"

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

    echo "Installing Joshuto to ${INSTALL_DIR}..."
    mkdir -p "$INSTALL_DIR"
    if [[ "$INSTALL_DIR" == /usr/local/bin ]]; then
        sudo mv "/tmp/${JOSHUTO_FOLDER}/joshuto" "${INSTALL_DIR}"
        sudo chown root:root "${INSTALL_DIR}/joshuto"
        sudo chmod 0755 "${INSTALL_DIR}/joshuto"
    else
        mv "/tmp/${JOSHUTO_FOLDER}/joshuto" "${INSTALL_DIR}"
        chmod 0755 "${INSTALL_DIR}/joshuto"
    fi

    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to move Joshuto binary." >&2
        return 1
    fi

    if [[ ! -x "${INSTALL_DIR}/joshuto" ]]; then
        echo "Error: ${INSTALL_DIR}/joshuto is not executable. Check permissions." >&2
        return 1
    fi

    # 4. 清理临时文件
    echo "Cleaning up..."
    rm "/tmp/${JOSHUTO_COMPRESSED_FILE}"
    rm -fr "/tmp/${JOSHUTO_FOLDER}"

    # 5. 验证安装
    echo "Verifying installation..."
    "${INSTALL_DIR}/joshuto" version

    if [[ $? -eq 0 ]]; then
        echo "Joshuto installed successfully."
    else
        echo "Error: Joshuto installation verification failed." >&2
        return 1
    fi
}
