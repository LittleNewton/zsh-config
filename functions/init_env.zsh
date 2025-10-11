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
    export dapustor="/mnt/DapuStor_R5100_RAID-Z1"
    export  toshiba="/mnt/Toshiba_MG06S_RAID-Z1"
    export       wd="/mnt/WD_HC550_RAID-Z1"
    export      cd2="/mnt/CloudDrive"

    export  app_data="${dapustor}/app_data"  # To be deprecated
    export  appdata="${dapustor}/AppData"
    export      doc="${dapustor}/Documents"
    export     soft="${dapustor}/Software"
    export     repo="${dapustor}/git_repo"

    # Media management, only for db_jav
    export     mdcx="${dapustor}/mdcx"
    export   failed="${mdcx}/failed"
    export      tmm="${doc}/tmm"

    # CloudDrive mount points
    export   pan115="${cd2}/115"
    export panbaidu="${cd2}/baidudrive"
    export   panali="${cd2}/aliyundrive"

    # Netdisk media storage, o:online
    export   jellyo="${pan115}/db_jellyfin"
    export    mdcxo="${pan115}/mdcx"
    export  failedo="${mdcxo}/failed"
    export     tmmo="${pan115}/tmm"
    export   javdbo="${jellyo}/db_jav"
    export   aavdbo="${jellyo}/db_aav"
    export   cavdbo="${jellyo}/db_cav"
    export moviedbo="${jellyo}/db_movie"
    export    tvdbo="${jellyo}/db_tv_series"
    export  favodbo="${jellyo}/db_favorite"

    # Local media storage, l:local
    export    media="${wd}/Media"
    export   jellyl="${media}/db_jellyfin"
    export    mdcxl="${jellyl}/mdcx"
    export  failedl="${mdcxl}/failed"
    export     tmml="${jellyl}/tmm"
    export   javdbl="${jellyl}/db_jav"
    export   aavdbl="${jellyl}/db_aav"
    export   cavdbl="${jellyl}/db_cav"
    export moviedbl="${jellyl}/db_movie"
    export    tvdbl="${jellyl}/db_tv_series"
    export  favodbl="${jellyl}/db_favorite"

    # Jellyfin database
    export    jelly="${appdata}/Jellyfin"
    export   jmedia="${jelly}/media"
    export    javdb="${jmedia}/db_jav"
    export    aavdb="${jmedia}/db_aav"
    export    cavdb="${jmedia}/db_cav"
    export  moviedb="${jmedia}/db_movie"
    export     tvdb="${jmedia}/db_tv_series"
    export   favodb="${jmedia}/db_favorite"

    # Other useful directories
    export     bins="${soft}/software_linux/bins"
    export download="${toshiba}/Downloads"
    export   xunlei="${download}/Xunlei_Downloads"
    export     qbit="${download}/qBittorrent_Downloads"
    export      byr="${qbit}/byr"

elif [[ $os_type == "macOS" ]]; then
    export      doc="/Volumes/Documents"
    export     soft="/Volumes/Software"
    export      cd2="${HOME}/CloudDrive"

    export   pan115="${cd2}/115"
    export panbaidu="${cd2}/baidudrive"
    export   panali="${cd2}/aliyundrive"


    export download="/Volumes/Downloads"
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
    export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
    export JAVA_HOME="/opt/homebrew/opt/openjdk"

    # Arm Toolchain
    export PATH="${HOME}/bin/arm-none-eabi/bin:$PATH"
    export PATH="${HOME}/bin/arm-none-eabi/arm-none-eabi/bin:$PATH"

    # Ghidra
    export GHIDRA_VERSION="11.1.2"
    export GHIDRA="${HOME}/bin/ghidra/ghidra_${GHIDRA_VERSION}_PUBLIC"
    export PATH="$GHIDRA/support:$PATH"

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
