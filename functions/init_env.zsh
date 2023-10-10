# Editor
export EDITOR='nvim'


# TrueNAS 特殊设置
if [[ $os_type == "TrueNAS_SCALE" ]]; then
    # 补全 PATH 变量，否则普通 sudo 用户无法使用 zpool 命令
    export PATH=$PATH:/sbin
    export PATH=$PATH:/mnt/Intel_750_RAID-Z1/newton/bin
fi
export     PATH=${HOME}/bin/:$PATH


# 存储池相关目录
export    intel="/mnt/Intel_750_RAID-Z1"
export  samsung="/mnt/Samsung_PM983A_RAID-Z1"
export  toshiba="/mnt/Toshiba_MG06S_RAID-Z1"
export       wd="/mnt/WD_HC550_RAID-Z1"

export  appdata="${intel}/app_data"
export      doc="${intel}/Documents"

export     soft="${samsung}/Software"

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

# 其他相关
export   harbor="app-registry.proxy.littlenewton.cn"
