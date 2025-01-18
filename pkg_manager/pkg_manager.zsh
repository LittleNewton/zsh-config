function ltnt_install() {

    # 检查是否在支持的系统上运行
    if [[ -z "$os_type" ]]; then
        echo "Error: os_type is not defined. Please set it before running this script." >&2
        return 1
    fi
    # 获取当前脚本所在的绝对路径
    local module_dir=$(dirname $(realpath ${(%):-%x}))/module

    if [[ $os_type == "Debian" || $os_type == "TrueNAS_SCALE" ]]; then
        if [[ $# -eq 0 ]]; then
            echo "Error: No package specified. Usage: ltnt_install <package_name>" >&2
            return 1
        fi

        local package=$1

        case $package in
        joshuto)
            if [[ -f "${module_dir}/joshuto.zsh" ]]; then
                source "${module_dir}/joshuto.zsh"
                install_joshuto
            else
                echo "Error: joshuto installation script not found in ${module_dir}/joshuto.zsh" >&2
                return 1
            fi
            ;;
        lazygit)
            if [[ -f "${module_dir}/lazygit.zsh" ]]; then
                source "${module_dir}/lazygit.zsh"
                install_lazygit
            else
                echo "Error: lazygit installation script not found in ${module_dir}/lazygit.zsh" >&2
                return 1
            fi
            ;;
        neovim)
            if [[ -f "${module_dir}/nvim.zsh" ]]; then
                source "${module_dir}/nvim.zsh"
                install_nvim
            else
                echo "Error: nvim installation script not found in ${module_dir}/nvim.zsh" >&2
                return 1
            fi
            ;;
        all)
            echo "Installing all available packages in ${module_dir}..."
            for script in ${module_dir}/*.zsh; do
                if [[ -f "$script" ]]; then
                    echo "Sourcing and executing $script..."
                    source "$script"
                    script_name=$(basename "$script" .zsh)
                    install_function="install_${script_name}"
                    if command -v $install_function >/dev/null 2>&1; then
                        $install_function
                    else
                        echo "Warning: Install function $install_function not found in $script." >&2
                    fi
                fi
            done
            ;;
        *)
            echo "Error: Unsupported package '$package'." >&2
            return 1
            ;;
        esac
    else
        echo "Error: Unsupported OS type '$os_type'. This script only supports Debian or TrueNAS SCALE." >&2
        return 1
    fi
}
