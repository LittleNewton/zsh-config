get_os_type() {

    local os_type
    if [[ $(uname -s) == "Linux" ]]; then
        os_type=$(grep -i '^NAME' /etc/os-release)

        # A. TrueNAS SCALE
        if [[ $(uname -r) == *"truenas"* ]]; then
            os_type="TrueNAS_SCALE"

        # B. OpenWrt
        elif [[ $os_type == *"OpenWrt"* ]]; then
            os_type="OpenWrt"

        # C. Debian
        elif [[ $os_type == *"Debian"* ]]; then
            os_type="Debian"

        # D. RedHat
        elif [[ $os_type == *"Red Hat Enterprise Linux"* ]]; then
            os_type="RedHat"

        # E. Ubuntu
        elif [[ $os_type == *"Ubuntu"* ]]; then
            os_type="Ubuntu"

        # F. FreeBSD
        elif [[ $os_type == *"FreeBSD"* ]]; then
            os_type="FreeBSD"

        # G. Manjaro 
        elif [[ $os_type == *"Manjaro"* ]]; then
            os_type="Manjaro"

        else
            os_type="Linux (Unknown Distribution)"
        fi

    elif [[ $(uname -s) == "Darwin" ]]; then
        os_type="macOS"
    else
        os_type="unknown"
    fi

    echo $os_type
}

export os_type=$(get_os_type)
