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
    if [ $# -eq 0 ]; then
        print -- "Usage: remote-exe <command>"
        return 1
    fi

    local command="$*" server command_result
    local -a failed_hosts=()

    for server in "${ServerInfo[@]}"; do
        print -- "===================================== ↓ ↓ ↓ ====================================="
        print -r -- "Run command '$command' on $server"
        if ssh "$server" "$command"; then
            print -r -- "Command on $server is done."
        else
            command_result=$?
            failed_hosts+=("$server (exit $command_result)")
            print -u2 -r -- "ERROR: Command on $server failed (exit $command_result)."
        fi
        print
    done

    if (( ${#failed_hosts} )); then
        print -u2 -r -- "Failed hosts: ${(j:, :)failed_hosts}"
        return 1
    fi
    print -- "All remote jobs completed successfully."
    return 0
}

function remote-update() {
    remote-exe "source ~/.config/zsh/.zshrc && os-update"
}
