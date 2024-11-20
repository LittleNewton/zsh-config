# 全局服务器信息
ServerInfo=(
    "hostname:5820-debian; ip:10.1.2.21; port:21221"
    "hostname:4950-debian; ip:10.2.2.21; port:22221"
    "hostname:r740-debian; ip:10.2.4.21; port:22421"
    "hostname:z690-debian; ip:10.2.5.21; port:22521"
    "hostname:x1e-debian;  ip:10.2.6.21; port:22621"
    "hostname:x299-debian; ip:10.2.7.21; port:22721"
    "hostname:gtr7-debian; ip:gtr7-debian; port:22"
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
        serverName=$(echo "$server" | awk -F'[:;]' '{print $2}' | xargs)
        serverAddr=$(echo "$server" | awk -F'[:;]' '{print $4}' | xargs)
        serverPort=$(echo "$server" | awk -F'[:;]' '{print $6}' | xargs)

        echo "===================================== ↓ ↓ ↓ =====================================" | lolcat
        echo "Run command '$command' on $serverName" | lolcat
        ssh -p "$serverPort" "$localUsername@$serverAddr" "$command"
        echo "Command on $serverName is done." | lolcat
        echo ""
    done

    echo "All remote jobs are done." | lolcat
    echo ""
}

function remote-update() {
    remote-exe "source ~/.config/zsh/.zshrc && os-update"
}
