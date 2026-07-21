export NVM_DIR="$HOME/.config/nvm"

if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    # zim 的 environment 模块开启了 EXTENDED_GLOB，会导致 nvm.sh 内部
    # `${VAR%%#*}` 之类的模式匹配报 "bad pattern: #*"，进而让 source 时
    # 自动执行的 `nvm use default` 静默失败，PATH 里就不会出现 node。
    [[ -o extendedglob ]] && _nvm_restore_extendedglob=1 || _nvm_restore_extendedglob=0
    unsetopt extendedglob
    . "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
    (( _nvm_restore_extendedglob )) && setopt extendedglob
    unset _nvm_restore_extendedglob
fi
