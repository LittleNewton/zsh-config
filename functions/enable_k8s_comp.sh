function enable_k8s_autocompletion {
    if command -v kubectl >/dev/null 2>&1; then
        if kubectl get node $(hostname) -o=jsonpath='{.metadata.labels}' | grep -q 'node-role.kubernetes.io/control-plane'; then
            source ${XDG_CONFIG_HOME}/zsh/kubeadm_auto_completion.sh
            source ${XDG_CONFIG_HOME}/zsh/kubectl_auto_completion.sh
        fi
    fi
}

check_and_enable_k8s_autocompletion() {
    local current_hostname=$(hostname)
    if [[ "$current_hostname" == "epyc-debian" ]]; then
        enable_k8s_autocompletion;
    fi
}

check_and_enable_k8s_autocompletion;

