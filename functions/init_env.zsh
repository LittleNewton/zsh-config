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

    # Homebrew 在 TrueNAS SCALE 上安装在 /usr/local 目录下，添加到 PATH 中
    export HOMEBREW_PREFIX="$HOME/.homebrew"
    export PATH="$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH"
fi

# Mamba 相关配置
export DEFAULT_MAMBA_ENV="py314"

# 存储池相关目录
if [[ $os_type == "Debian" || $os_type == "TrueNAS_SCALE" ]]; then
    # Level 1: Storage Pools
    # samsung and wd are local on r740-debian, other hosts mount them over NFS
    # at the same paths; dapustor is local on 4950-debian.
    export  samsung="/mnt/Samsung_PM9A3_Stripe"
    export dapustor="/mnt/DapuStor_R5100_RAID-Z1"
    export       wd="/mnt/WD_HC550_RAID-Z1"
    export      cd2="/mnt/CloudDrive"

    # Level 2: Main Directories
    export  appdata="${samsung}/AppData"
    export   backup="${samsung}/Backup"
    export      doc="${samsung}/Documents"
    export     repo="${dapustor}/Develop"
    export     work="${samsung}/Work"
    export     soft="${backup}/installers"
    export download="${wd}/Downloads"

    # Media management, only for MDCx and tinyMediaManager
    export     mdcx="${work}/mdcx"
    export   failed="${mdcx}/failed"
    export      tmm="${download}/tmm"

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
    export   media2="${samsung}/Media"
    export   musedb="${media2}/Music"
    export    imgdb="${media2}/Pictures"
    export  videodb="${media2}/Videos"

    # Local video storage on SSD
    export   famidb="${videodb}/db_family"
    export   favodb="${videodb}/db_favorite"
    export   gamedb="${videodb}/db_game"
    export   livedb="${videodb}/db_live"
    export    outdb="${videodb}/db_cinema"
    export  diarydb="${videodb}/db_diary"
    export   escodb="${videodb}/db_escort"

    # Jellyfin database, metadata/strm files only
    export    jelly="${appdata}/Jellyfin"
    export   jmedia="${jelly}/media"
    export    javdb="${jmedia}/db_jav"
    export  moviedb="${jmedia}/db_movie"
    export     tvdb="${jmedia}/db_tv_series"

    # Other useful directories
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
    export openwrt="${repo}/openwrt/openwrt"
fi

# macOS 特殊路径
if [[ $os_type == "macOS" ]]; then
    # NeoVim
    export PATH="${HOME}/bin/nvim/bin:$PATH"

    # Homebrew binary
    export PATH="/opt/homebrew/bin:$PATH"

    # Arm Toolchain
    export PATH="$HOME/.local/opt/arm-none-eabi/bin:$PATH"
    export PATH="$HOME/.local/opt/arm-none-eabi/arm-none-eabi/bin:$PATH"

    # Ghidra
    export GHIDRA_VERSION="12.0.3"
    export GHIDRA="${HOME}/.local/opt/ghidra_${GHIDRA_VERSION}_PUBLIC"
    export PATH="$GHIDRA/support:$PATH"
    export GHIDRA_INSTALL_DIR="${HOME}/.local/opt/ghidra_${GHIDRA_VERSION}_PUBLIC"

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
    [[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
fi

# Ghidra 相关
if [[ $os_type == "Debian" ]]; then
    export GHIDRA_VERSION="12.0.4"
    export GHIDRA="${HOME}/.local/opt/ghidra_${GHIDRA_VERSION}_PUBLIC"
    export PATH="$GHIDRA/support:$PATH"
fi

# Preserve a valid user-selected JVM; otherwise detect the installed JVM
# using the current OS rather than a fixed Java version or CPU architecture.
_init_java_home() {
    if [[ -n "$JAVA_HOME" && -x "$JAVA_HOME/bin/java" ]]; then
        export JAVA_HOME
        return 0
    fi

    local detected_java_home="" java_binary
    case "$os_type" in
        macOS)
            if [[ -x /usr/libexec/java_home ]]; then
                detected_java_home=$(/usr/libexec/java_home 2>/dev/null) || detected_java_home=""
            fi
            ;;
        Debian|Ubuntu|TrueNAS_SCALE)
            java_binary=$(whence -p java)
            if [[ -n "$java_binary" ]]; then
                java_binary=${java_binary:A}
                detected_java_home=${java_binary:h:h}
            fi
            ;;
    esac
    if [[ -n "$detected_java_home" && -x "$detected_java_home/bin/java" ]]; then
        export JAVA_HOME="$detected_java_home"
    else
        unset JAVA_HOME
    fi
}

case "$os_type" in
    macOS|Debian|Ubuntu|TrueNAS_SCALE)
        _init_java_home
        if [[ "$os_type" == macOS && -n "$JAVA_HOME" ]]; then
            export PATH="$JAVA_HOME/bin:$PATH"
        fi
        ;;
esac

# Another bin
export PATH="$HOME/.local/bin:$PATH"

# OpenWrt (musl libc 内建 UTF-8，设置 locale 即可)
if [[ $os_type == "OpenWrt" ]]; then
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
fi

# $HOME 的可执行文件目录
export PATH="$PATH:$HOME/bin"
