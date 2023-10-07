# * DESCRIPTION: Oh-My-Zsh / zsh Configuration File
# * Author: 刘鹏 / Peng Liu
# * Email: littleNewton6@gmail.com
# * Date Created: 2020, Jun.  27
# * Data Updated: 2023, Sept. 25





autoload colors; colors

#======================== oh-my-zsh 设置 BEGIN ========================
# (1) zsh 安装位置
export ZSH="/home/newton/.config/oh-my-zsh"

# (2) 获取系统类型
if [[ `uname -s` == "Linux" ]]; then
    os_type=$(cat /etc/os-release | grep -i '^NAME')

    # A. TrueNAS SCALE
    if [[ `uname -r` == *"truenas"* ]]; then
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
    else [[ $os_type == *"FreeBSD"* ]]
        os_type="FreeBSD"

    fi
elif [[ `uname -s` == "Darwin" ]]; then
    os_type="macOS"
else
    os_type="unknown"
fi

# zsh 主题，软件默认的是 robbyrussell
ZSH_THEME="agnoster"

# 自动补全大小写敏感设置为 false
CASE_SENSITIVE="false"

# 开启自动更新
export UPDATE_ZSH_DAYS=1
DISABLE_AUTO_UPDATE="true"

# 开启自动纠正错误
ENABLE_CORRECTION="true"
#======================== oh-my-zsh 设置  END  ========================





#======================== 插件配置 BEGIN ========================
plugins=(
    bundler
    dotenv
    fzf-zsh-plugin
    git
    macos
    rake
    rbenv
    ruby
		zsh-autosuggestions
		zsh-syntax-highlighting
)
#======================== 插件配置  END  ========================





#======================== 启用 oh-my-zsh 配置 BEGIN ========================
source $ZSH/oh-my-zsh.sh
#======================== 启用 oh-my-zsh 配置  END  ========================





#======================== pip 设置 BEGIN ========================
# (1) pip 默认设置为 pip3
alias pip='pip3'
alias ipython='ipython3'
# (2) pip 自动补全
function _pip_completion {
    local words cword
    read -Ac words
    read -cn cword
    reply=( $( COMP_WORDS="$words[*]" \
            COMP_CWORD=$(( cword-1 )) \
    PIP_AUTO_COMPLETE=1 $words[1] ) )
}
compctl -K _pip_completion pip3
# (3) 设置 Python3-pip 的自动更新函数
function _pip_update () {
    pip3 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 sudo -H pip3 install -U
}
#======================== pip 设置  END  ========================





#======================== 别名 BEGIN ========================
alias ll='ls -lFh'
alias la='ls -a'
alias l='ls -1'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias dir='ls'
alias ip='ip -color'
alias dirs='dirs -lpv'
#======================== 别名  END  ========================





#======================== Terminal Color BEGIN ========================
LS_COLORS=$LS_COLORS:'di=0;36' ; export LS_COLORS
#======================== Terminal Color  END  ========================





#======================== TeXLive 配置 BEGIN ========================
# TeX Live 的相关设置：
# (1) 导入系统的参考手册
# (2) TeX Live 配置与系统类型有关，与 Linux 发行版无关，因此只需用 uname 查询内核即可
is_texlive_installed="false"
function _set_texlive () {
    # (1) 判断 texlive 是否已安装
    texlive_folder='/usr/local/texlive/'
    if [ -d ${texlive_folder} ]; then
        max_texlive_version=`ls -1 -r ${texlive_folder} | grep -E '20*' | head -n 1`
        if [[ -n ${max_texlive_version} ]]; then

            # A. 更改环境变量
            is_texlive_installed="true"

            # B. 设置操作系统对应的环境变量
            if [[ $os_type == "macOS" ]]; then
                export MANPATH=/usr/local/texlive/${max_texlive_version}/texmf-dist/doc/man:${MANPATH}
                export INFOPATH=/usr/local/texlive/${max_texlive_version}/texmf-dist/doc/info:${INFOPATH}
                export PATH=/usr/local/texlive/${max_texlive_version}/bin/universal-darwin:${PATH}
            elif [[ $os_type == "Linux" ]]; then
                export MANPATH=/usr/local/texlive/${max_texlive_version}/texmf-dist/doc/man:${MANPATH}
                export INFOPATH=/usr/local/texlive/${max_texlive_version}/texmf-dist/doc/info:${INFOPATH}
                export PATH=/usr/local/texlive/${max_texlive_version}/bin/x86_64-linux:${PATH}
            else
                # 抛出异常，等待日后处理此类系统类型
                echo "系统类型无法识别"
            fi
        fi
    fi
}
# (2) 执行 set_texlive 函数
_set_texlive;
#======================== TeXLive 配置  END  ========================





#======================== UPDATE 设置 BEGIN ========================
# 系统自动更新，该函数不区分系统
function os-update () {
    # (1) 更新 TeX Live
    print -P "%F{cyan}Step 1/3 tlmgr update%f"
    if [[ $is_texlive_installed == "true" ]]; then
        sudo tlmgr update --self --all
    elif [[ $is_texlive_installed == "false" ]]; then
        print -P "%F{white}INFO: No installation of texlive was detected, please check it%f"
    fi

    # (2) 更新 miniconda Python，不使用系统 Python
    print -P "%F{cyan}Step 2/3: Updating Miniconda%f"
    print -P "%F{white}NOTE: Only the base virtual environment will be updated.%f"
    conda activate base
    conda upgrade -n base --yes --all

    # (3) 更新系统包管理器下的软件
    case $os_type in
        macOS)
            print -P "%F{cyan}Step 3/3: Updating macOS Homebrew%f"
            brew update
            brew upgrade
            ;;
        Ubuntu)
            if command -v apt-get >/dev/null 2>&1; then
                print -P "%F{cyan}Step 3/3: Updating Ubuntu%f"

                cmds=(
                    "sudo apt-get update"
                    "sudo apt-get upgrade --just-print"
                    "sudo apt-get upgrade"
                    "sudo apt-get dist-upgrade"
                    "sudo apt-get -y autoremove"
                    "sudo apt-get -y autoclean"
                )

                for cmd in "${cmds[@]}"; do
                    echo
                    print -P "%F{yellow}> $cmd%f"
                    eval $cmd
                done
            else
                print -P "%F{red}ERROR: System package manager not supported.%f"
            fi
            ;;
        Debian)
            if command -v apt-get >/dev/null 2>&1; then
                print -P "%F{cyan}Step 3/3: Updating Debian%f"

                cmds=(
                    "sudo apt-get update"
                    "sudo apt-get upgrade --just-print"
                    "sudo apt-get upgrade"
                    "sudo apt-get dist-upgrade"
                    "sudo apt-get -y autoremove"
                    "sudo apt-get -y autoclean"
                )

                for cmd in "${cmds[@]}"; do
                    echo
                    print -P "%F{yellow}> $cmd%f"
                    eval $cmd
                done
            else
                print -P "%F{red}ERROR: System package manager not supported.%f"
            fi
            ;;
        RedHat)
            if command -v yum >/dev/null 2>&1; then
                echo $fg[cyan]Step 3/3: Updating RedHat$reset_color
                sudo yum update
            else
                print -P "%F{red}ERROR: System package manager not supported.%f"
            fi
            ;;
        *)
            print -P "%F{red}ERROR: Unsupported operating system: $os_type.%f"
            ;;
    esac
}
#======================== UPDATE 设置  END  ========================





#======================== REMOTE UPDATE BEGIN =========================
function remote-update() {
    declare -A debianServers=(
        ["5820-debian"]=(
            ["Host"]="10.1.2.21"
            ["Port"]="21221"
        )
        ["epyc-debian"]=(
            ["Host"]="10.2.1.21"
            ["Port"]="22121"
        )
        ["z690-debian"]=(
            ["Host"]="10.2.3.21"
            ["Port"]="22321"
        )
        ["r740-debian"]=(
            ["Host"]="10.2.4.21"
            ["Port"]="22421"
        )
        ["t630-debian"]=(
            ["Host"]="10.2.5.21"
            ["Port"]="22521"
        )
        ["nipc-debian"]=(
            ["Host"]="124.16.71.120"
            ["Port"]="10121"
        )
        ["7060-debian"]=(
            ["Host"]="10.3.1.21"
            ["Port"]="23121"
        )
        ["x1e-debian"]=(
            ["Host"]="10.3.2.21"
            ["Port"]="23221"
        )
        ["x299-debian"]=(
            ["Host"]="10.3.3.21"
            ["Port"]="23321"
        )
    )

    local localUsername="newton"

    for server in ${(k)debianServers}; do
        serverName=$server
        serverInfo=$debianServers[$server]
        serverHost=$serverInfo[Host]
        serverPort=$serverInfo[Port]

        # Upgrade
        echo "===================================== ↓ ↓ ↓ =====================================" | lolcat
        echo "$serverName is getting updated" | lolcat
        ssh "$localUsername@$serverHost" "-p $serverPort" "source ~/.zshrc && os-update"
        echo "$serverName upgrading done" | lolcat
        echo ""
    done

    echo "All upgrading jobs are done." | lolcat
    echo ""
}
#======================================== REMOTE UPDATE END =================================================





#======================== oh-my-zsh 插件 BEGIN ========================
#source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
#======================== oh-my-zsh 插件  END  ========================





#======================== zsh Key-Binding BEGIN ========================
# 防止 SSH Shell 某些键失效
bindkey "\e[1~" beginning-of-line
bindkey "\e[4~" end-of-line
bindkey "\e[5~" beginning-of-history
bindkey "\e[6~" end-of-history

# for rxvt
bindkey "\e[8~" end-of-line
bindkey "\e[7~" beginning-of-line
# for non RH/Debian xterm, can't hurt for RH/DEbian xterm
bindkey "\eOH" beginning-of-line
bindkey "\eOF" end-of-line
# for freebsd console
bindkey "\e[H" beginning-of-line
bindkey "\e[F" end-of-line
# completion in the middle of a line
bindkey '^i' expand-or-complete-prefix

# Fix numeric keypad
# 0 . Enter
bindkey -s "^[Op" "0"
bindkey -s "^[On" "."
bindkey -s "^[OM" "^M"
# 1 2 3
bindkey -s "^[Oq" "1"
bindkey -s "^[Or" "2"
bindkey -s "^[Os" "3"
# 4 5 6
bindkey -s "^[Ot" "4"
bindkey -s "^[Ou" "5"
bindkey -s "^[Ov" "6"
# 7 8 9
bindkey -s "^[Ow" "7"
bindkey -s "^[Ox" "8"
bindkey -s "^[Oy" "9"
# + - * /
bindkey -s "^[Ol" "+"
bindkey -s "^[Om" "-"
bindkey -s "^[Oj" "*"
bindkey -s "^[Oo" "/"
#======================== zsh Key-Binding  END  ========================





#======================== 环境变量 BEGIN ========================
export EDITOR='nvim'
if [[ $os_type == "TrueNAS_SCALE" ]]; then
    # 补全 PATH 变量，否则普通 sudo 用户无法使用 zpool 命令
    export PATH=$PATH:/sbin
    export PATH=$PATH:/mnt/Intel_750_RAID-Z1/newton/bin
fi  

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
export     PATH=${HOME}/bin/:$PATH
#======================== 环境变量  END  ========================


if [[ $os_type == "TrueNAS_SCALE" ]]; then

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/mnt/Intel_750_RAID-Z1/newton/bin/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/mnt/Intel_750_RAID-Z1/newton/bin/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/mnt/Intel_750_RAID-Z1/newton/bin/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/mnt/Intel_750_RAID-Z1/newton/bin/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

elif [[ $os_type == "Debian" ]]; then

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/newton/bin/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/newton/bin/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/newton/bin/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/newton/bin/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

else
    echo "Unsupported OS type: $os_type"
fi



#======================== K8S BEGIN  ========================
function enable_k8s_autocompletion {
    if command -v kubectl >/dev/null 2>&1; then
        if kubectl get node $(hostname) -o=jsonpath='{.metadata.labels}' | grep -q 'node-role.kubernetes.io/control-plane'; then
            source ${HOME}/.config/zsh/kubeadm_auto_completion.sh
            source ${HOME}/.config/zsh/kubectl_auto_completion.sh
        fi
    fi
}
current_hostname=$(hostname)

if [[ "$current_hostname" == "epyc-debian" ]]; then
    enable_k8s_autocompletion;
fi
#======================== K8S  END  ========================

# 很多语言都没办法使用包管理器安装，只能手动管理
export PATH=$PATH:/usr/local/bin/julia/bin


# XDG 规范的路径
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$XDG_CONFIG_HOME/local/share"
export XDG_CACHE_HOME="$XDG_CONFIG_HOME/cache"

# Zsh related config file.
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export HISTFILE="$ZDOTDIR/.zhistory"    # History filepath
export HISTSIZE=10000                   # Maximum events for internal history
export SAVEHIST=10000                   # Maximum events in history file
