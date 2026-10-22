# findmnt uses exit 1 for both an empty result and some errors. Check that the
# table is readable and capture diagnostics before treating exit 1 as no match.
_nfs_findmnt() {
    if ! command -v findmnt >/dev/null 2>&1; then
        print -u2 -- "ERROR: NFS management requires findmnt (util-linux)."
        return 1
    fi
    local table_file
    case "$1" in
        --fstab) table_file=/etc/fstab ;;
        --kernel) table_file=/proc/self/mountinfo ;;
        *) print -u2 -- "ERROR: Invalid mount table."; return 1 ;;
    esac
    if [[ ! -r "$table_file" ]]; then
        print -u2 -r -- "ERROR: Cannot read mount table: $table_file"
        return 1
    fi

    local error_file output diagnostics query_result=0
    error_file=$(mktemp "${TMPDIR:-/tmp}/zsh-findmnt.XXXXXXXX") || return 1
    output=$(findmnt "$@" 2>"$error_file") || query_result=$?
    diagnostics=$(<"$error_file")
    rm -f -- "$error_file"
    if (( query_result == 0 )) && [[ -z "$diagnostics" ]]; then
        [[ -z "$output" ]] || print -r -- "$output"
        return 0
    elif (( query_result == 1 )) && [[ -z "$output" && -z "$diagnostics" ]]; then
        return 0
    fi
    print -u2 -r -- "ERROR: findmnt could not query $table_file (exit $query_result)."
    [[ -z "$diagnostics" ]] || print -u2 -r -- "$diagnostics"
    return 1
}

# Read NFS targets from the client's fstab or current mount table.
# Server addresses, paths and transport options are maintained in fstab.
_nfs_targets() {
    local table=$1 entries target
    entries=$(_nfs_findmnt "$table" --raw --noheadings --types nfs,nfs4 --output TARGET) || return 1
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
    _nfs_findmnt --kernel --raw --noheadings --nocanonicalize \
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
        if ! fs_type=$(_nfs_mount_type "$target"); then
            result=1
            continue
        fi
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
        if ! fs_type=$(_nfs_mount_type "$target"); then
            result=1
            continue
        fi
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
