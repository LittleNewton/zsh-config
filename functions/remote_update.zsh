function remote-update() {
    ServerInfo=(
        "hostname:5820-debian; ip:10.1.2.21; port:21221"
        "hostname:4950-debian; ip:10.2.2.21; port:22221"
        "hostname:r740-debian; ip:10.2.4.21; port:22421"
        "hostname:z690-debian; ip:10.2.5.21; port:22521"
        "hostname:x1e-debian;  ip:10.2.6.21; port:22621"
        "hostname:x299-debian; ip:10.2.7.21; port:22721"
    )

    local localUsername="newton"

    for server in "${ServerInfo[@]}"; do
        # Using awk to extract each part of the server info
        serverName=$(echo $server | awk -F'[:;]' '{print $2}' | xargs)
        serverAddr=$(echo $server | awk -F'[:;]' '{print $4}' | xargs)
        serverPort=$(echo $server | awk -F'[:;]' '{print $6}' | xargs)

        # Upgrade
        echo "===================================== ↓ ↓ ↓ =====================================" | lolcat
        echo "$serverName is getting updated" | lolcat
        ssh "$localUsername@$serverAddr" "-p $serverPort" "source ~/.config/zsh/.zshrc && os-update"
        echo "$serverName upgrading done" | lolcat
        echo ""
    done

    echo "All upgrading jobs are done." | lolcat
    echo ""
}
