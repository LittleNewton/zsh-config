# 自动补全函数
function _ltnt_install_completion() {
    local cur_word supported_packages
    cur_word="$words[2]"                     # 当前补全的单词
    supported_packages=("joshuto" "lazygit" "neovim") # 支持的包名

    # 生成补全列表
    compadd -- "${supported_packages[@]}"
}

# 绑定补全函数到 ltnt_install
compdef _ltnt_install_completion ltnt_install
