---

# date: 2026-03-13 21:53:44

现在请你测试我这个 zsh 启动脚本。

- 测试基础：docker debian:trixie
- 测试流程：

1. 在全新的环境里安装必要的组件，如 bzip2, git, zsh, curl
2. 安装 这个 zsh 环境。安装方法在 readme.md 里有说明。
3. 配置 python 环境，主要是 micromamba 部分，在 functions/init_mamba.zsh 里有说明，主要是：

```
mkdir -p "$HOME/.local/bin"
curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xOj bin/micromamba > "$HOME/.local/bin/micromamba"
chmod +x "$HOME/.local/bin/micromamba"
ln -sf "$HOME/.local/bin/micromamba" "$HOME/.local/bin/mamba"

# Only use conda-forge
tee "$HOME/.condarc" >/dev/null <<'EOF'
channels:
  - conda-forge
channel_priority: strict
auto_activate_base: false
EOF
```
4. pkg_manager 部分，安装几个常用软件。
5. 其他你认为有必要的测试。

请你总结所有可能的警告、错误。