init_zsh() {
    # Check if `XDG_DATA_HOME` is defined
    if [[ -z "${XDG_DATA_HOME}" ]]; then
        echo "ERROR: XDG_DATA_HOME is not defined."
        return 1
    fi

    # check if ${XDG_DATA_HOME}/oh-my-zsh exists
    if [[ -d "${XDG_DATA_HOME}/oh-my-zsh" ]]; then
        source ${ZSH}/oh-my-zsh.sh
        return 0
    else
        echo "${XDG_DATA_HOME}/oh-my-zsh not exists,"
        echo "now clone oh-my-zsh to ${XDG_DATA_HOME}/oh-my-zsh."
        git clone https://github.com/ohmyzsh/ohmyzsh.git "${XDG_DATA_HOME}/oh-my-zsh"
        echo "clone oh-my-zsh done."
    fi
}

# Run it.
init_zsh;
