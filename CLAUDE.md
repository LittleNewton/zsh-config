# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) or Codex when working with code in this repository.

## What this repo is

A personal Zsh configuration (`$ZDOTDIR=$XDG_CONFIG_HOME/zsh`) that runs across **macOS, Debian/Ubuntu, TrueNAS SCALE, OpenWrt, FreeBSD, Manjaro**. The same checked-out tree is dropped onto every host the user owns; behavior diverges at runtime based on detected OS and short hostname, not via per-host branches.

Plugin manager is **zimfw** (configured in `.zimrc`, installed lazily into `$ZIM_HOME=$XDG_DATA_HOME/zim`). `oh-my-zsh` is cloned to `$XDG_DATA_HOME/oh-my-zsh` only to source a few plugin files referenced from `.zimrc`.

## Boot flow

`.zshrc` sources, in this order, files under `functions/` and then `pkg_manager/pkg_manager.zsh` + `completion/`. The order matters:

1. `get_os_type.zsh` — sets `export os_type` (Debian / Ubuntu / macOS / TrueNAS_SCALE / OpenWrt / Manjaro / Arch / Alpine / Fedora / RedHat / FreeBSD). TrueNAS SCALE is detected via `uname -r` *before* `/etc/os-release` (which would otherwise report Debian).
2. `init_env.zsh` — `$PATH`, editor, and a large set of named storage-pool / media directory exports (`$dapustor`, `$jelly`, `$javdb`, `$pan115`, …). These exports are conditional on `$os_type` and sometimes on `$HOST` (e.g. `$openwrt` only on `4950-debian`, `$uk` only on `gtr7-debian`).
3. `init_alias.zsh`, `init_plugin.zsh` (bootstraps zimfw + oh-my-zsh on first run), `init_mapping.zsh` (keybindings for SSH/numpad), `init_mamba.zsh`, `init_nvm.zsh`, `init_latex.zsh`.
4. `os_update.zsh`, `mount_management.zsh`, `remote_update.zsh`, `init_tmux.zsh`.
5. `pkg_manager/pkg_manager.zsh` and the `ltnt_install` completion.

Downstream files assume `$os_type` is already set. When adding a new `functions/*.zsh`, source it from `.zshrc` and gate OS-specific blocks on `$os_type` rather than re-running `uname`.

## The four user-facing commands

- **`init-tmux [-f|--force]`** (`functions/init_tmux.zsh`) — runs `tmux/$(hostname -s).sh`. Each script in `tmux/` builds a session named `normal` with a host-specific pane layout (shell + `iotop` + `zpool iostat` + `btop`/`nvitop`). `-f` kills the existing `normal` session after a y/N confirm. To support a new host, add `tmux/<short-hostname>.sh` (executable, model it on `tmux/z690-debian.sh`).
- **`os-update`** (`functions/os_update.zsh`) — runs four numbered phases in order: TeX Live (`tlmgr`), `micromamba` (only the `$DEFAULT_MAMBA_ENV` env, default `py314`), `nvm` + global npm, then OS packages (`brew` / `apt-get` / `yum` depending on `$os_type`). Each phase no-ops with an INFO message if the tool isn't installed.
- **`remote-exe <cmd>` / `remote-update`** (`functions/remote_update.zsh`) — fan out to the hard-coded `ServerInfo` array via `ssh`. `remote-update` is just `remote-exe "source ~/.config/zsh/.zshrc && os-update"`. Hosts in `ServerInfo` must also exist in `~/.ssh/config` (the canonical template is `config/ssh_entries`).
- **`ltnt_install <package> [--dest system|user]`** (`pkg_manager/`) — installs `joshuto`, `lazygit`, `neovim`, `yazi`, or `all`. On macOS it shells out to `brew` and ignores `--dest`. On Debian/Ubuntu/TrueNAS_SCALE it sources `pkg_manager/module/<pkg>.zsh` and calls `install_<pkg> <install_dir>`. See `pkg_manager/CLAUDE.md` for arch normalization, libc detection, and the `neovim → nvim` naming mismatch — read it before touching anything under `pkg_manager/`.

## Conventions to preserve

- **Don't hardcode hostnames or OS names** in widely-loaded files. Gate on `$os_type` (set once at startup) and on `$HOST` only for one-off paths that genuinely exist on a single machine.
- **Don't run `uname -m` directly** in package install logic — go through `_ltnt_normalize_linux_arch` and `_ltnt_asset_arch` (see `pkg_manager/CLAUDE.md`).
- **TeX Live note**: shell init can't fix `sudo tlmgr` because `sudo`'s `secure_path` excludes TeX Live's bin. The fix is a one-time `sudo $(which tlmgr) path add` on the host — don't try to work around it in `.zshrc`.
- **TrueNAS SCALE PATH**: `/sbin` must be appended for non-root users to run `zpool` (already handled in `init_env.zsh`).

## Validation

There is no test suite. Before committing changes to any `*.zsh`:

```bash
zsh -n path/to/file.zsh    # syntax check
```

For shell files under `tmux/` (bash shebang):

```bash
bash -n tmux/<host>.sh
```

To smoke-test a change to the boot flow, open a fresh interactive shell (`zsh -i -c 'echo ok'`) — `init_plugin.zsh` will re-bootstrap missing zimfw modules on first run, which is expected.
