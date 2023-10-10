export is_texlive_installed="false"

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

_set_texlive;
