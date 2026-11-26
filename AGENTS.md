# AGENTS.md

## 仓库定位

这是跨主机共用的个人 Zsh 配置。同一份代码按操作系统和主机名在运行时分流，不维护每台主机的独立分支。默认用简体中文交流。

- 部署位置为 `$XDG_CONFIG_HOME/zsh`，`ZDOTDIR` 指向该目录。`~/.zshenv` 中的 XDG 变量、`ZDOTDIR` 和 `ZIM_HOME` 由仓库外配置，初始化示例见 `README.md`。
- 插件由 zimfw 管理，清单为 `.zimrc`，安装位置为 `$ZIM_HOME`（通常是 `$XDG_DATA_HOME/zim`）。oh-my-zsh 只提供部分插件，下载到 `$XDG_DATA_HOME/oh-my-zsh`。
- 操作系统识别范围不等于各命令的支持范围；修改前检查对应函数的分支。
- 修改 `pkg_manager/` 前先读 `pkg_manager/CLAUDE.md`，其中维护安装模块的详细约定。

## 启动入口与依赖顺序

`.zshrc` 显式依次加载以下文件；新增初始化文件也要在这里接入：

1. `functions/get_os_type.zsh`：导出 `os_type`。TrueNAS SCALE 优先通过内核名识别，再读取 `/etc/os-release`。
2. `functions/init_env.zsh`：设置 PATH、编辑器、存储路径、`DEFAULT_MAMBA_ENV` 和 Java 环境。
3. `functions/init_alias.zsh` → `init_plugin.zsh` → `init_mapping.zsh`：别名、插件和键绑定。
4. `functions/init_mamba.zsh` → `init_nvm.zsh` → `init_latex.zsh`：开发工具环境。
5. `functions/os_update.zsh` → `mount_management.zsh` → `remote_update.zsh` → `init_tmux.zsh`：管理命令。
6. `pkg_manager/pkg_manager.zsh` → `completion/ltnt_install_completion.zsh`：安装入口与补全。两个 Kubernetes 补全文件当前未启用。

后续模块依赖已设置的 `os_type`；系统分支复用它，不重复探测。`.zimrc` 的补全、语法高亮和历史搜索模块存在顺序要求，调整时保留这些依赖。

## 主要命令与维护入口

### 批量执行与更新

- `functions/remote_update.zsh` 中的 `ServerInfo` 是 `remote-exe` / `remote-update` 共用的显式主机名单，不从 SSH 配置自动枚举。
- `remote-exe <command>` 通过 SSH **逐台**执行；单台失败后继续，最后汇总失败主机并返回非零状态。
- `remote-update` 执行 `remote-exe "source ~/.config/zsh/.zshrc && os-update"`。
- `config/ssh_entries` 是实际 `~/.ssh/config` 的仓库快照；同步时保留主机别名一致性。新增 SSH 条目不代表加入批量升级，NAS、Windows、路由器和交换机另行管理。
- 主机迁移或退役时，核对 `ServerInfo`、SSH 快照、`tmux/` 和 `init_env.zsh` 中的主机专属路径，避免只改一处。

`functions/os_update.zsh` 的 `os-update` 分四阶段运行：

1. TeX Live；
2. micromamba：仅更新 `DEFAULT_MAMBA_ENV`（当前在 `init_env.zsh` 中设为 `py314`），然后清理缓存；
3. nvm 自身、受 nvm 管理的 Node.js 最新长期支持版，以及 npm 和全局包；
4. 系统包：macOS 用 Homebrew，Debian/Ubuntu 用 apt-get，RedHat 用 yum。

前三阶段有工具缺失时的跳过逻辑，系统包阶段对不支持的系统返回失败。阶段内命令失败后停止该阶段，后续阶段仍执行；最终汇总失败阶段并返回非零状态。维护时保留错误传播，不能让最后一条成功输出掩盖前面的失败。

### NFS 挂载

`functions/mount_management.zsh` 提供 `mount_nfs` / `unmount_nfs`，依赖 Linux 的 `findmnt` 和挂载表：

- 服务端、路径和挂载参数来自客户端 `/etc/fstab`，不在脚本中复制维护。
- `mount_nfs` 处理配置中的 NFS 挂载点，跳过已挂载的 NFS，拒绝覆盖其他文件系统。
- `unmount_nfs` 只处理配置目标及其下级的 NFS 挂载，先卸载子路径。
- `_nfs_findmnt` 区分空结果和查询失败；判断文件系统时检查精确挂载点，不能把父目录的文件系统当成目标。

### tmux 布局

- `init-tmux [-f|--force]` 位于 `functions/init_tmux.zsh`，兼容别名为 `init_tmux`。
- 按短主机名执行 `tmux/<host>.sh`；优先使用含 `tmux/` 的 `ZDOTDIR`，否则使用 `${XDG_CONFIG_HOME:-$HOME/.config}/zsh`。
- 各脚本维护 `normal` 会话；已有会话时直接连接。`--force` 经 y/N 确认后删除该会话再初始化。
- 新脚本需可执行，并按目标主机核对工具、存储池和布局；不要直接照搬另一台主机的命令。

### 软件安装

`ltnt_install <package> [--dest system|user]` 支持 `joshuto`、`lazygit`、`neovim`、`yazi` 和 `all`。

- macOS 统一走 Homebrew，安装位置由 Homebrew 管理。
- Debian/Ubuntu/TrueNAS_SCALE 调用 `pkg_manager/module/` 下的模块；默认安装到 `/usr/local/bin`，`--dest user` 安装到 `~/.local/bin`。
- 命令参数为 `neovim`，对应模块和函数为 `nvim.zsh` / `install_nvim`。新增包时同步入口、模块和补全。
- 架构与 libc 检测复用 `_ltnt_normalize_linux_arch`、`_ltnt_asset_arch`、`_ltnt_detect_linux_libc`；模块不另写一套 `uname -m` 映射。下载文件名以实际发布资源为准。
- Linux 的 `all` 会继续安装其余包并汇总失败，单包安装也必须正确返回失败状态。

## 环境配置中需要保留的行为

- 通用配置按 `os_type` 分流；只有确实属于单机的路径才按主机名分流。存储环境变量的定义不代表目录已经挂载，修改前检查调用方与实际路径。
- `_init_java_home` 保留有效的用户 `JAVA_HOME`，否则按当前系统探测；不要重新写死 Java 版本或 CPU 架构。
- `init_nvm.zsh` 在加载 nvm 时临时关闭 `EXTENDED_GLOB`，结束后恢复原状态；这是为避免 zim 的选项导致 nvm 出现 `bad pattern: #*`。
- TrueNAS SCALE 为普通用户补充 `/sbin`，以便找到 `zpool`。
- `sudo tlmgr` 找不到命令是 sudo 的 PATH 问题；在目标主机核实后可一次性运行 `sudo "$(command -v tlmgr)" path add`，不要用 `.zshrc` 绕过。

## 验证

仓库没有自动化测试套件。按改动范围执行：

```sh
zsh -n path/to/changed.zsh
bash -n tmux/<host>.sh
git diff --check
```

修改启动流程后，用 `zsh -i -c 'echo ok'` 检查交互式启动，并核对目标变量或命令；注意 shell 实际加载的是 `ZDOTDIR` 指向的配置。首次启动可能下载插件，micromamba 初始化也可能激活环境。

修改错误处理时，用替身命令模拟失败，检查后续阶段是否继续、最终退出状态是否正确。实际升级、批量 SSH、安装、挂载或重建 tmux 会话有真实副作用，不作为普通语法检查执行。仅文档改动核对路径、说明与实现，并运行差异检查即可。
