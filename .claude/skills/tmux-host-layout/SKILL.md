---
name: tmux-host-layout
description: 为本仓库（$ZDOTDIR/tmux/）创建或更新某台主机的 tmux init 脚本——新主机没有 tmux/<hostname>.sh 时新建一份，或者已有脚本但用户已经手动调整过当前 "normal" session 的窗口/pane 布局、要求下次 init-tmux 用新布局时重写现有脚本。当用户说「给这台机器建一个 tmux 配置」「新机器要写 tmux 初始化脚本」「我调整了 tmux 布局，把配置更新一下」「同步一下 tmux 的 pane 布局」时使用。**必须**警惕 tmux-powerline 状态栏导致的新建 session 时"差一行"问题，见下文。
---

# tmux 主机初始化脚本 Skill

本仓库（`$ZDOTDIR` = `~/.config/zsh`）用 `tmux/<short-hostname>.sh` 管理每台主机的 tmux 布局，由 `functions/init_tmux.zsh` 里的 `init-tmux` 命令调度：读取 `hostname -s`，执行 `tmux/$host.sh`。所有脚本都创建/attach 一个叫 `normal` 的 session。约定和坑参见仓库根 `CLAUDE.md`，本 skill 补充实操细节。

## 0. 先分清楚是"新建"还是"更新"

- `tmux/<hostname>.sh` **不存在** → 走 §1 新建流程。
- `tmux/<hostname>.sh` **已存在**，用户说"我调整了布局"/"同步一下当前配置" → 走 §2 更新流程。**不要凭用户口头描述去猜布局，永远实测**——用户经常只记得大概，实测出来的 pane 尺寸和口头描述对不上是常态（参考本 skill 编写时的真实过程：用户说"两个 pane 都要加 1"，实测发现其中一个根本没变、另一个方向反了，最后追出来是 tmux-powerline 的坑，见 §3）。

## 1. 新建主机脚本

1. 确认 short hostname：`hostname -s`。
2. 看 `tmux/` 下有没有硬件/角色相近的现成脚本可以当模板（`tmux/z690-debian.sh` 是 CLAUDE.md 里点名的范本）。核对新主机实际情况会不会不一样：
   - 有几块盘、组成什么 zpool（`zpool list -H -o name`，不要瞎编池名）
   - 有没有独显（有则起 `nvitop` 窗口而不是只有 `btop`，参照 `tmux/z690-debian.sh` 的窗口 3）
   - `os_type` 是否会影响命令可用性（比如 TrueNAS SCALE 上 `zpool` 需要 `/sbin` 在 PATH 里，已在 `init_env.zsh` 处理，脚本本身不用管）
3. 两种写法二选一：
   - 如果用户已经在这台机器上手动搭好了一个 `normal` session 作为"这就是我要的样子"，直接走 §2 的实测流程去采集，只是目标文件是新建而不是覆盖。
   - 如果没有现成 session，跟用户确认窗口/pane 数量和用途（一般至少要有：主窗口的 shell + iotop + zpool iostat 三件套、一个 `btop`/`nvitop` 窗口），照 §1.2 的骨架写。
4. 骨架（和现有所有脚本一致，不要随意改变量命名风格）：

```bash
#!/bin/bash

# tmux initialization script for session 'normal'
SESSION_NAME="normal"

# Check if session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Session '$SESSION_NAME' already exists. Attaching..."
    tmux attach-session -t "$SESSION_NAME"
    exit 0
fi

# Create new session with first window named 'main'
tmux new-session -d -s "$SESSION_NAME" -n main -c "$HOME" -x "$(tput cols)" -y "$(tput lines)"

# ... split-window / resize-pane / send-keys，见 §2 采集出的结构 ...

# Select the first window and shell pane, matching the current <hostname> session
tmux select-window -t "$SESSION_NAME:main"
tmux select-pane -t "$shell_pane"

# Attach to the session
tmux attach-session -t "$SESSION_NAME"
```

5. `chmod +x tmux/<hostname>.sh`。
6. `bash -n tmux/<hostname>.sh` 语法检查（脚本是 bash shebang，不是 zsh，CLAUDE.md 里也是这么要求的）。
7. 提醒用户：新脚本要靠 `init-tmux` 实际跑一次才能验证效果，光看 diff 看不出 tmux-powerline 那个坑（见 §3）。

## 2. 更新已有主机脚本（同步当前布局）

目标是把用户已经手动调好的 `normal` session 的真实结构，原样写回 `tmux/<hostname>.sh`。**全程靠命令实测，不要靠回忆或猜**。

### 2.1 采集窗口结构

```bash
tmux list-windows -t normal -F "#{window_index}: #{window_name} layout=#{window_layout} active=#{window_active}"
```

对比脚本里现有的 `tmux new-window -n <name>` 数量和顺序，找出新增/删除/改名的窗口。

### 2.2 采集每个 pane 的尺寸和内容

```bash
tmux list-panes -t normal -a -F "win=#{window_index}:#{window_name} pane=#{pane_index} id=#{pane_id} active=#{pane_active} left=#{pane_left} top=#{pane_top} w=#{pane_width} h=#{pane_height} cmd=#{pane_current_command} path=#{pane_current_path}"
```

`pane_current_command` 只给进程名（比如 `sudo`、`watch`），看不到参数。要拿到完整命令行（比如 `iotop` 的具体 flag、`watch` 里监控的 zpool 池名单）必须往下钻：

```bash
for pid in $(tmux list-panes -t normal -a -F "#{pane_pid}"); do
  echo "=== pane_pid=$pid ==="
  pstree -p -a "$pid"
done
```

这一步很重要——池名单、iotop 参数这些细节经常会变（比如新加了一块盘、新建了一个 zpool），脚本里写死的旧参数会悄悄过时，不实测就会把过时的值继续抄进新脚本。需要交叉核对时用 `zpool list -H -o name` 确认当前真实存在的池。

### 2.3 把尺寸映射回脚本里的 split-window / resize-pane

现有脚本的套路是：先 `split-window -h/-v -p N` 按百分比粗分，再用 `resize-pane -t <pane> -x/-y N` 精确指定一侧的绝对尺寸（另一侧靠剩余空间自动决定，脚本里不显式写）。更新时：

- 保持变量名（`shell_pane` / `zpool_pane` / `left_iotop_pane` / `right_iotop_pane` 等）和 pane 创建顺序不变，只改 `resize-pane` 后面的绝对值——这样 diff 小、可读性好。
- 只有百分比切分本身也变了（比如列宽比例变了）才去动 `split-window -p N`。
- 新增/删除的窗口，模仿脚本里 `codec` / `fuzzing` 这类"空窗口"的写法（`tmux new-window -t "$SESSION_NAME" -n <name> -c "$HOME"`，不预置命令，让用户手动起进程）——除非该窗口本来就该固定跑一个命令（像 `btop` 窗口那样用 `send-keys`）。

### 2.4 改完之后

1. `bash -n tmux/<hostname>.sh`。
2. 明确告诉用户：改动只有跑一次 `init-tmux -f`（杀掉旧 session、重新走"新建+attach"全流程）才能验证，不能靠在已经 attach 的旧 session 里继续手动拖 pane 边框来验证——原因见 §3，那条路径根本走不到新建 session 时的 bug。

## 3. 警惕：tmux-powerline 导致的"新建 session 时差一行"

本机（以及任何装了状态栏插件的主机）都可能踩这个坑，**每次改 pane 高度相关的绝对值之前都要先确认一下**。

### 3.1 根因

- `tmux new-session -d ... -x "$(tput cols)" -y "$(tput lines)"`：`tput lines` 读的是当前物理终端的总行数，这一步完全不知道 tmux 状态栏还要占地方。
- 本机装了 `erikw/tmux-powerline`（`~/.config/tmux/tmux.conf` 里 `set -g @plugin 'erikw/tmux-powerline'`），它在 `main.tmux` 里执行 `tmux set-option -g status "$TMUX_POWERLINE_STATUS_VISIBILITY"`，默认值 `"on"`，也就是标准单行状态栏（除非用户设了 `TMUX_POWERLINE_STATUS_VISIBILITY=2` 才是双行）。
- session 是 `-d` 创建的，创建瞬间没有 client 约束，所以脚本里所有 `split-window -p N` / `resize-pane -y N` 都是在"偏大 1 行"的画布上算出来的。等脚本最后 `tmux attach-session` 真正接上一个物理终端时，tmux 才需要为状态栏收回 1 行，窗口被迫收缩，pane 高度跟着变。

### 3.2 已确认的实际表现（2026-07-25，4950-debian 上验证过）

- 差值精确等于 **1 行**（单行状态栏），且这 1 行从"每组 split 里第一个创建、后来被显式 `resize-pane -y N` 指定绝对高度"的那个 pane 身上扣掉，另一侧（靠剩余空间自动决定高度的 pane）不受影响。
- 这个偏差**只发生在"新建 session → attach"这条冷启动路径上**。在一个已经 attach、状态栏已经生效很久的 session 里手动拖动 pane 边框，看到的尺寸变化是"干净"的、不会重现这个 bug——所以想验证这个坑，必须用 `init-tmux -f` 走一遍完整冷启动，而不是在当前 session 里现场量。

### 3.3 应对

两种做法，看用户想不想根治：

- **快速补丁**（改一个脚本、赶时间时用）：把该脚本里所有用绝对值指定高度的 `resize-pane -y N`（以及理论上同理的 `-x N`，虽然目前只在垂直方向验证过）都 **+1**，抵消 attach 时的收缩。这是最初给 4950-debian.sh 打的补丁方式。
- **根治**（改 `functions/init_tmux.zsh` 或每个脚本的 session 创建行，一次性解决所有主机）：把
  ```bash
  tmux new-session -d -s "$SESSION_NAME" -n main -c "$HOME" -x "$(tput cols)" -y "$(tput lines)"
  ```
  的 `-y "$(tput lines)"` 改成显式减去状态栏占用的行数，例如单行状态栏减 1：
  ```bash
  -y "$(( $(tput lines) - 1 ))"
  ```
  如果确认是双行状态栏（`TMUX_POWERLINE_STATUS_VISIBILITY=2`）就减 2。这样后续所有百分比切分和绝对 resize 都建立在"真实可用行数"上，不需要再对单个 pane 打补丁。**改这里之前跟用户确认要不要一次性动所有主机脚本**，因为这是一处会影响每个 `tmux/*.sh` 的通用改动，不只是当前在改的这一台。

### 3.4 判断某台主机是否需要关心这个坑

```bash
grep -n "@plugin" ~/.config/tmux/tmux.conf   # 看有没有状态栏类插件（powerline / tmux-status 等）
tmux show-options -g status                  # off = 没这个坑；on/2/3... = 有，且数值就是要减掉的行数
tmux list-clients -F "client_height=#{client_height}"   # 物理终端真实行数
tmux display-message -p "#{window_height}"               # 当前 attach 状态下窗口实际可用行数
```

两者之差就是状态栏吃掉的行数（正常应该等于 `status` 的数值，`off` 记为 0）。如果某台主机没有启用状态栏，`tput lines` 和实际可用行数一致，不需要任何 +1 补偿，别把这个坑的补丁无脑抄过去。
