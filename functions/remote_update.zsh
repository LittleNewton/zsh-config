function remote-update() {
    typeset -A ServerInfo=(
        ["5820-debian"]="ip:10.1.2.21; port:21221"
        ["4950-debian"]="ip:10.2.2.21; port:22221"
        ["r740-debian"]="ip:10.2.4.21; port:22421"
        ["z690-debian"]="ip:10.2.5.21; port:22521"
        ["x1e-debian"]="ip:10.2.6.21; port:22621"
        ["x299-debian"]="ip:10.2.7.21; port:22721"
    )

    local localUsername="newton"

    for server in ${(k)ServerInfo}; do
        serverName=$server
        serverHost=$(echo $ServerInfo[$server] | awk -F'[:;]' '{print $2}')
        serverPort=$(echo $ServerInfo[$server] | awk -F'[:;]' '{print $4}')

        # Upgrade
        echo "===================================== ↓ ↓ ↓ =====================================" | lolcat
        echo "$serverName is getting updated" | lolcat
        ssh "$localUsername@$serverHost" "-p $serverPort" "source ~/.config/zsh/.zshrc && os-update"
        echo "$serverName upgrading done" | lolcat
        echo ""
    done

    echo "All upgrading jobs are done." | lolcat
    echo ""
}
