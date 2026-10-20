# 批量执行/更新的主机白名单；每项必须存在于 ~/.ssh/config。
# SSH 配置还包含 NAS、Windows、路由器等设备，不应全部加入此列表。
ServerInfo=(
    5820-debian
    4950-debian
    r740-debian
    z690-debian
    7060-debian
    gtr7-debian
    pi5-debian
)

function remote-exe() {
    local localUsername="newton"

    if [ $# -eq 0 ]; then
        echo "Usage: remote-exe <command>" | lolcat
        return 1
    fi

    local command="$*"

    for server in "${ServerInfo[@]}"; do
        # Using awk to extract each part of the server info

        echo "===================================== ↓ ↓ ↓ =====================================" | lolcat
        echo "Run command '$command' on $server" | lolcat
        ssh "$server" "$command"
        echo "Command on $server is done." | lolcat
        echo ""
    done

    echo "All remote jobs are done." | lolcat
    echo ""
}

function remote-update() {
    remote-exe "source ~/.config/zsh/.zshrc && os-update"
}
