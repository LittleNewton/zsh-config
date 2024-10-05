# Editor
export EDITOR='nvim'

# My GitHub
export github="git@github.com:LittleNewton"


# TrueNAS 特殊设置
if [[ $os_type == "TrueNAS_SCALE" ]]; then
    # 补全 PATH 变量，否则普通 sudo 用户无法使用 zpool 命令
    export PATH=$PATH:/sbin
    export PATH=$PATH:/mnt/Intel_750_RAID-Z1/newton/bin
fi


# 存储池相关目录
if [[ $os_type == "Debian" || $os_type == "TrueNAS_SCALE" ]]; then
    export dapustor="/mnt/DapuStor_R5100_RAID-Z1"
    export  toshiba="/mnt/Toshiba_MG06S_RAID-Z1"
    export       wd="/mnt/WD_HC550_RAID-Z1"
    export  appdata="${dapustor}/app_data"

    export      doc="${dapustor}/Documents"
    export     soft="${dapustor}/Software"

    export download="${toshiba}/Downloads"
    export   xunlei="${download}/Xunlei_Downloads"
    export     qbit="${download}/qBittorrent_Downloads"
    export      byr="${qbit}/byr"

    export    media="${wd}/Media"
    export    javdb="${media}/db_jellyfin/db_jav"
    export    aavdb="${media}/db_jellyfin/db_aav"
    export    cavdb="${media}/db_jellyfin/db_cav"

    export jellyfin="${media}/db_jellyfin"
    export     mdcx="${jellyfin}/mdcx"
    export      tmm="${jellyfin}/tmm"
    export   failed="${mdcx}/failed"
elif [[ $os_type == "macOS" ]]; then
    export      doc="/Volumes/Documents"
    export     soft="/Volumes/Software"

    export download="/Volumes/Downloads/"
    export   xunlei="${download}/Xunlei_Downloads"
    export     qbit="${download}/qBittorrent_Downloads"
    export      byr="${qbit}/byr"

    export    media="/Volumes/Media"
    export    javdb="${media}/db_jellyfin/db_jav"
    export    aavdb="${media}/db_jellyfin/db_aav"
    export    cavdb="${media}/db_jellyfin/db_cav"

    export jellyfin="${media}/db_jellyfin"
    export     mdcx="${jellyfin}/mdcx"
    export      tmm="${jellyfin}/tmm"
    export   failed="${mdcx}/failed"

    export       uk="/Volumes/NAS_in_UK/Documents"
fi

# 编译 OpenWrt 相关
if [[ $HOST == "4950-debian" ]]; then
    export openwrt="${dapustor}/openwrt-compile/openwrt/"
fi

# macOS 特殊路径
if [[ $os_type == "macOS" ]]; then
    export PATH=/Users/newton/bin/nvim/bin:$PATH
    export PATH=/opt/homebrew/bin:$PATH

    # Java related envs.
    export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
    export JAVA_HOME="/opt/homebrew/opt/openjdk"

    # Arm toolchain
    export PATH="/Users/newton/bin/arm-none-eabi/bin:$PATH"
    export PATH="/Users/newton/bin/arm-none-eabi/arm-none-eabi/bin:$PATH"

    # Ghidra
    export GHIDRA_VERSION="11.1.2"
    export GHIDRA="/Users/newton/bin/ghidra/ghidra_${GHIDRA_VERSION}_PUBLIC"
    export PATH="$GHIDRA/support:$PATH"
fi


# 其他相关
export   harbor="app-registry.proxy.littlenewton.cn"


# Go 语言相关
if [[ $os_type == "Debian" || $os_type == "TrueNAS_SCALE" ]]; then
    export GOPATH="$HOME/.local/share/go"
    export PATH="$PATH:/usr/local/go/bin"
fi

# Rust 语言相关
if [[ $os_type == "Debian" ]]; then
    source "$HOME/.cargo/env"
fi

# PATH 相关
export PATH="$PATH:$HOME/bin"
