function remote-update() {
    declare -A debianServers=(
        ["5820-debian"]=(
            ["Host"]="10.1.2.21"
            ["Port"]="21221"
        )
        ["4950-debian"]=(
            ["Host"]="10.2.2.21"
            ["Port"]="22221"
        )
        ["z690-debian"]=(
            ["Host"]="10.2.3.21"
            ["Port"]="22321"
        )
        ["r740-debian"]=(
            ["Host"]="10.2.4.21"
            ["Port"]="22421"
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
