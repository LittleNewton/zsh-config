# Read NFS targets from the client's fstab or current mount table.
# Server addresses, paths and transport options are maintained in fstab.
_nfs_targets() {
    local table=$1 entries target

    if ! command -v findmnt >/dev/null 2>&1; then
        print -u2 -- "ERROR: NFS management requires findmnt (util-linux)."
        return 1
    fi

    # findmnt exits with 1 when no matching NFS entries exist.
    entries=$(findmnt "$table" --raw --noheadings --types nfs,nfs4 --output TARGET)
    while IFS= read -r target; do
        # --raw hex-escapes whitespace and other unsafe characters.
        printf -v target '%b' "$target"
        [[ -n "$target" ]] || continue
        target=${target%/}
        print -r -- "${target:-/}"
    done <<< "$entries"
    return 0
}

# Get the topmost filesystem at this exact mountpoint, not its parent.
_nfs_mount_type() {
    findmnt --kernel --raw --noheadings --nocanonicalize \
        --direction backward --first-only --mountpoint "$1" --output FSTYPE
}

# Mount the NFS shares configured on this client in /etc/fstab.
mount_nfs() {
    local targets target fs_type result=0
    targets=$(_nfs_targets --fstab) || return 1
    if [[ -z "$targets" ]]; then
        print -- "INFO: No NFS shares configured in /etc/fstab."
        return 0
    fi

    # Sorting also puts any explicitly configured parent before its children.
    local -a ordered_targets=("${(@f)targets}")
    for target in "${(@ou)ordered_targets}"; do
        fs_type=$(_nfs_mount_type "$target")
        case "$fs_type" in
            nfs|nfs4)
                print -r -- "INFO: Already mounted: $target"
                ;;
            ""|autofs)
                print -r -- "Mounting NFS share: $target"
                if ! sudo mount -- "$target"; then
                    print -u2 -r -- "ERROR: Failed to mount: $target"
                    result=1
                fi
                ;;
            *)
                print -u2 -r -- "ERROR: Refusing to cover a $fs_type mount: $target"
                result=1
                ;;
        esac
    done
    return "$result"
}

# Unmount only NFS at fstab targets and their descendants, children first.
# Local filesystems and unrelated NFS mounts are left alone.
unmount_nfs() {
    local configured mounted target parent fs_type result=0
    configured=$(_nfs_targets --fstab) || return 1
    if [[ -z "$configured" ]]; then
        print -- "INFO: No NFS shares configured in /etc/fstab."
        return 0
    fi

    mounted=$(_nfs_targets --kernel) || return 1
    local -a configured_targets=("${(@f)configured}") ordered_targets=()
    for target in "${(@f)mounted}"; do
        for parent in "${configured_targets[@]}"; do
            if [[ "$target" == "$parent" || "$target" == "${parent%/}/"* ]]; then
                ordered_targets+=("$target")
                break
            fi
        done
    done
    if (( ${#ordered_targets} == 0 )); then
        print -- "INFO: No configured NFS shares are mounted."
        return 0
    fi

    for target in "${(@Ou)ordered_targets}"; do
        fs_type=$(_nfs_mount_type "$target")
        case "$fs_type" in
            nfs|nfs4)
                print -r -- "Unmounting NFS share: $target"
                if ! sudo umount -- "$target"; then
                    print -u2 -r -- "ERROR: Failed to unmount: $target"
                    result=1
                fi
                ;;
            *)
                print -u2 -r -- "ERROR: No accessible NFS mount at: $target"
                result=1
                ;;
        esac
    done
    return "$result"
}
