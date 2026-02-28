# Editor
export EDITOR='nvim'

# My GitHub
export github="git@github.com:LittleNewton"

# Self-hosted container registry
export harbor="app-registry.littlenewton.cn"

# TrueNAS 特殊设置
if [[ $os_type == "TrueNAS_SCALE" ]]; then
    # 补全 PATH 变量，否则普通 sudo 用户无法使用 zpool 命令
    export PATH=$PATH:/sbin
fi

# 存储池相关目录
if [[ $os_type == "Debian" || $os_type == "TrueNAS_SCALE" ]]; then
    # Level 1: Storage Pools
    export dapustor="/mnt/DapuStor_R5100_RAID-Z1"
    export  toshiba="/mnt/Toshiba_MG06S_RAID-Z1"
    export       wd="/mnt/WD_HC550_RAID-Z1"
    export      cd2="/mnt/CloudDrive"

    # Level 2: Main Directories
    export  appdata="${dapustor}/AppData"
    export      doc="${dapustor}/Documents"
    export     repo="${dapustor}/Develop"
    export     soft="${doc}/installer"

    # Media management, only for MDCx and tinyMediaManager
    export     mdcx="${doc}/mdcx"
    export   failed="${mdcx}/failed"
    export      tmm="${doc}/tmm"

    # CloudDrive mount points
    export   pan115="${cd2}/115"
    export  pan115s="${cd2}/115_small"
    export panbaidu="${cd2}/baidudrive"
    export   panali="${cd2}/aliyundrive"

    # NetDrive media storage, on Large pan115, o:online
    export   jellyo="${pan115}/db_jellyfin"
    export    mdcxo="${pan115}/mdcx"
    export  failedo="${mdcxo}/failed"
    export     tmmo="${pan115}/tmm"
    export   javdbo="${jellyo}/db_jav"
    export moviedbo="${jellyo}/db_movie"
    export    tvdbo="${jellyo}/db_tv_series"

    # NetDrive media storage, on Small pan115, o:online
    export   jellys="${pan115s}/db_jellyfin"
    export   aavdbo="${jellys}/db_aav"
    export animedbo="${jellys}/db_anime"
    export   cavdbo="${jellys}/db_cav"
    export  musedbo="${jellys}/db_music"

    # Local media storage on HDD
    export    media="${wd}/Media"
    export   jellyl="${media}/db_jellyfin"
    export   aavdbl="${jellyl}/db_aav"
    export   animel="${jellyl}/db_anime"
    export   cavdbl="${jellyl}/db_cav"
    export     edul="${jellyl}/db_education"

    # Local media storage on SSD
    export   media2="${dapustor}/Media"
    export   musedb="${media2}/Music"
    export    imgdb="${media2}/Pictures"
    export  videodb="${media2}/Videos"

    # Local video storage on SSD
    export   famidb="${videodb}/db_family"
    export   favodb="${videodb}/db_favorite"
    export   gamedb="${videodb}/db_game"
    export   livedb="${videodb}/db_live"
    export    outdb="${videodb}/db_cinema"
    export    devdb="${videodb}/via_devices"

    # Jellyfin database, metadata/strm files only
    export    jelly="${appdata}/Jellyfin"
    export   jmedia="${jelly}/media"
    export    javdb="${jmedia}/db_jav"
    export  moviedb="${jmedia}/db_movie"
    export     tvdb="${jmedia}/db_tv_series"

    # Other useful directories
    export     bins="${soft}/software_linux/bins"
    export download="${toshiba}/Downloads"
    export   xunlei="${download}/Xunlei_Downloads"
    export     qbit="${download}/qBittorrent_Downloads"
    export      byr="${qbit}/byr"

elif [[ $os_type == "macOS" ]]; then
    export      cd2="/Volumes/CloudDrive"
    export      doc="/Volumes/Documents"

    export   pan115="${cd2}/115"
    export  pan115s="${cd2}/115_small"
    export panbaidu="${cd2}/baidudrive"
    export   panali="${cd2}/aliyundrive"
fi

if [[ $HOST == "gtr7-debian" ]]; then
    export uk="/mnt/Samsung_990Pro_Stripe"
fi

# 编译 OpenWrt 相关
if [[ $HOST == "4950-debian" ]]; then
    export openwrt="/mnt/Intel_750_RAID-Z1/openwrt-compile/openwrt"
fi

# macOS 特殊路径
if [[ $os_type == "macOS" ]]; then
    # NeoVim
    export PATH="${HOME}/bin/nvim/bin:$PATH"

    # Homebrew binary
    export PATH="/opt/homebrew/bin:$PATH"

    # Java
    export JAVA_HOME="/Library/Java/JavaVirtualMachines/temurin-21.jdk/Contents/Home"
    export PATH="$JAVA_HOME/bin:$PATH"

    # Arm Toolchain
    export PATH="${HOME}/bin/arm-none-eabi/bin:$PATH"
    export PATH="${HOME}/bin/arm-none-eabi/arm-none-eabi/bin:$PATH"

    # Ghidra
    export GHIDRA_VERSION="12.0.3"
    export GHIDRA="${HOME}/bin/ghidra/ghidra_${GHIDRA_VERSION}_PUBLIC"
    export PATH="$GHIDRA/support:$PATH"
    export GHIDRA_INSTALL_DIR="${HOME}/bin/ghidra/ghidra_${GHIDRA_VERSION}_PUBLIC"

    # mtr
    export PATH="/opt/homebrew/Cellar/mtr/0.95/sbin/:$PATH"
fi

# Go 语言相关
if [[ $os_type == "Debian" || $os_type == "TrueNAS_SCALE" ]]; then
    export GOPATH="$HOME/.local/share/go"
    export PATH="$PATH:/usr/local/go/bin"
fi

# Rust 语言相关
if [[ $os_type == "Debian" ]]; then
    source "$HOME/.cargo/env"
fi

# Ghidra 相关
if [[ $os_type == "Debian" ]]; then
    export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
    export GHIDRA_VERSION="11.1.2"
    export GHIDRA="$HOME/bin/ghidra/ghidra_${GHIDRA_VERSION}_PUBLIC"
    export PATH="$GHIDRA/support:$PATH"
fi

# $HOME 的可执行文件目录
export PATH="$HOME/bin:$PATH"
