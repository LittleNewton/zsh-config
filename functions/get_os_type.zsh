get_os_type() {
    local kernel=$(uname -s)
    local os_type

    if [[ $kernel == Darwin ]]; then
        os_type="macOS"
    elif [[ $kernel == FreeBSD ]]; then
        os_type="FreeBSD"
    elif [[ $kernel != Linux ]]; then
        os_type="unknown"
    elif [[ $(uname -r) == *truenas* ]]; then
        # TrueNAS SCALE reports Debian in /etc/os-release, so detect it via the kernel name.
        os_type="TrueNAS_SCALE"
    elif [[ -r /etc/os-release ]]; then
        # Source in a sub-shell so NAME/VERSION/PRETTY_NAME/... don't leak into the caller's scope.
        local ID ID_LIKE
        ID=$(. /etc/os-release 2>/dev/null; echo "$ID")
        ID_LIKE=$(. /etc/os-release 2>/dev/null; echo "$ID_LIKE")
        case "$ID" in
            openwrt) os_type="OpenWrt" ;;
            debian)  os_type="Debian" ;;
            ubuntu)  os_type="Ubuntu" ;;
            manjaro) os_type="Manjaro" ;;
            arch)    os_type="Arch" ;;
            alpine)  os_type="Alpine" ;;
            fedora)  os_type="Fedora" ;;
            rhel|centos|rocky|almalinux) os_type="RedHat" ;;
            *)
                case " $ID_LIKE " in
                    *" rhel "*|*" fedora "*) os_type="RedHat" ;;
                    *" debian "*)            os_type="Debian" ;;
                    *" arch "*)              os_type="Arch" ;;
                    *)                       os_type="Linux (Unknown Distribution)" ;;
                esac
                ;;
        esac
    else
        os_type="Linux (Unknown Distribution)"
    fi

    echo "$os_type"
}

export os_type=$(get_os_type)
