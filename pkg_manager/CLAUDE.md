# pkg_manager Notes

This directory contains the `ltnt_install` entrypoint and per-package install modules.

## High-level flow

- Entry point: `pkg_manager/pkg_manager.zsh`
- Package modules: `pkg_manager/module/*.zsh`
- Supported package names at the CLI layer:
  - `joshuto`
  - `lazygit`
  - `neovim`
  - `yazi`
  - `all`

`ltnt_install` is responsible for:

- parsing `ltnt_install <package> [--dest system|user]`
- validating the package name early
- routing by OS
- exposing shared helpers for arch/libc mapping
- sourcing the matching module on Linux-like systems

## OS strategy

### macOS

macOS does not use the existing download/extract/install scripts.

Instead, `ltnt_install` switches to Homebrew:

- `joshuto -> brew install joshuto`
- `lazygit -> brew install lazygit`
- `neovim -> brew install neovim`
- `yazi -> brew install yazi`
- `all -> brew install joshuto lazygit neovim yazi`

Notes:

- `--dest` is ignored on macOS because Homebrew controls installation paths.
- If `brew` is missing, fail early with a clear error.
- Keep the macOS logic in the entrypoint, not duplicated in each module.

### Linux-like systems

Current intended support:

- `Debian`
- `Ubuntu`
- `TrueNAS_SCALE`

These systems still use module scripts that download release binaries and install them into:

- `system -> /usr/local/bin`
- `user -> ~/.local/bin`

## Architecture normalization

The key rule is: do not use raw `uname -m` directly inside each module.

Use the shared helper `_ltnt_normalize_linux_arch()` first:

- `x86_64` or `amd64` -> `x86_64`
- `aarch64` or `arm64` -> `aarch64`

This gives one canonical Linux arch name for internal logic.

## Asset-name mapping

Different upstream projects use different arch strings in release assets. Because of that, there is a second helper: `_ltnt_asset_arch <package>`.

### Canonical internal arch

- amd64/x86_64 family -> `x86_64`
- arm64/aarch64 family -> `aarch64`

### Package-specific asset mapping

- `joshuto`
  - `x86_64 -> x86_64`
  - `aarch64 -> aarch64`
- `yazi`
  - `x86_64 -> x86_64`
  - `aarch64 -> aarch64`
- `lazygit`
  - `x86_64 -> x86_64`
  - `aarch64 -> arm64`
- `nvim`
  - `x86_64 -> x86_64`
  - `aarch64 -> arm64`

Why this exists:

- some projects publish assets as `...x86_64...` / `...aarch64...`
- some projects publish assets as `...x86_64...` / `...arm64...`

If a new package is added, check its actual GitHub release asset names first, then extend `_ltnt_asset_arch()` accordingly.

## libc detection

Some Linux packages publish separate `gnu` and `musl` builds.

The helper `_ltnt_detect_linux_libc()` returns:

- `musl` if `ldd --version` reports musl, or musl loaders are found
- otherwise `gnu`

Current consumers:

- `joshuto`
- `yazi`

Selection rule:

1. try the asset for the detected libc
2. if missing, fall back to the other libc variant

This fallback matters because some upstream releases are not perfectly consistent across architectures or libc variants.

## Module-specific expectations

### `module/joshuto.zsh`

- fetch release metadata from GitHub releases
- resolve latest `tag_name`
- find an asset matching:
  - `joshuto-<tag>-<arch>-unknown-linux-<libc>.tar.gz`
- try detected libc first, then fallback

### `module/yazi.zsh`

- fetch latest release metadata
- find an asset matching:
  - `yazi-<arch>-unknown-linux-<libc>.zip`
- try detected libc first, then fallback

### `module/lazygit.zsh`

- fetch latest release metadata
- find Linux tarball by asset suffix
- current expected patterns are lowercase like:
  - `...linux_x86_64.tar.gz`
  - `...linux_arm64.tar.gz`
- matching is done with `ascii_downcase` to avoid case drift

### `module/nvim.zsh`

- Linux only in the module layer
- download `nvim-linux-<arch>.appimage`
- use `_ltnt_asset_arch nvim`
  - `x86_64`
  - `arm64`

## Naming mismatches to remember

- CLI package name: `neovim`
- Linux module filename: `module/nvim.zsh`
- Linux function name: `install_nvim`
- macOS brew formula: `neovim`

Do not collapse these accidentally without updating the entrypoint mapping.

## Rules for future changes

- Keep OS routing centralized in `pkg_manager.zsh`.
- Keep arch normalization centralized in helper functions.
- Do not hardcode `x86_64` in a package module unless the upstream really only ships that arch.
- Before changing asset names, verify the real upstream release naming scheme.
- Prefer reading GitHub release metadata and selecting an actual asset over building URLs from assumptions.
- When adding macOS support for a package already available in Homebrew, prefer brew routing over duplicating download/install logic.

## Safe extension checklist

When adding a new package:

1. decide whether macOS should use `brew`
2. inspect upstream release asset names
3. map canonical arch to upstream asset arch names
4. check whether `gnu` vs `musl` matters
5. keep module logic Linux-focused if macOS is already handled by brew
6. run `zsh -n` on the edited scripts

