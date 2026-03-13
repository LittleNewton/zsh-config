```bash
borg create --stats --progress h12-truenas:/mnt/DapuStor_R5100_RAID-Z1/Backup/backup_files/BorgBackup_for_WeChat::'{now:%Y-%m-%d_%H%M%S}' '/Volumes/WeChat Backup/xwechat_backup'
borg create --stats --progress gtr7-debian:/mnt/Samsung_990Pro_Stripe/uk_backup/WeChat/BorgBackup_for_WeChat::'{now:%Y-%m-%d_%H%M%S}' '/Volumes/WeChat Backup/xwechat_backup'


borg create --stats --progress h12-truenas:/mnt/DapuStor_R5100_RAID-Z1/Backup/backup_files/BorgBackup_for_QQ::'{now:%Y-%m-%d_%H%M%S}' '/Volumes/QQ Backup/qq_backup/'
borg create --stats --progress gtr7-debian:/mnt/Samsung_990Pro_Stripe/uk_backup/QQ/BorgBackup_for_QQ::'{now:%Y-%m-%d_%H%M%S}' '/Volumes/QQ Backup/qq_backup/'
borg create --stats --progress '/Volumes/SanDisk CZ880/BorgBackup_for_QQ'::'{now:%Y-%m-%d_%H%M%S}' '/Volumes/QQ Backup/qq_backup/'
```

我现在使用 borgbackup 进行自动化备份，但是我不想每次都复制粘贴上面这四个命令，因为这实在是太容易出错了。

请你参考下列命令，给我写几个

```bash
#!/bin/sh

# Setting this, so the repo does not need to be given on the commandline:
export BORG_REPO=ssh://username@example.com:2022/~/backup/main

# See the section "Passphrase notes" for more infos.
export BORG_PASSPHRASE='XYZl0ngandsecurepa_55_phrasea&&123'

# some helpers and error handling:
info() { printf "\n%s %s\n\n" "$( date )" "$*" >&2; }
trap 'echo $( date ) Backup interrupted >&2; exit 2' INT TERM

info "Starting backup"

# Back up the most important directories into an archive named after
# the machine this script is currently running on:

borg create                         \
    --verbose                       \
    --filter AME                    \
    --list                          \
    --stats                         \
    --show-rc                       \
    --compression lz4               \
    --exclude-caches                \
    --exclude 'home/*/.cache/*'     \
    --exclude 'var/tmp/*'           \
                                    \
    '{hostname}'                    \
    /etc                            \
    /home                           \
    /root                           \
    /var

backup_exit=$?

info "Pruning repository"

# Use the `prune` subcommand to maintain 7 daily, 4 weekly and 6 monthly
# archives of THIS machine. The '{hostname}' matching is very important to
# limit prune's operation to archives with exactly that name and not apply
# to archives with other names also:

borg prune               \
    '{hostname}'         \
    --list               \
    --show-rc            \
    --keep-daily    7    \
    --keep-weekly   4    \
    --keep-monthly  6

prune_exit=$?

# actually free repo disk space by compacting segments

info "Compacting repository"

borg compact -v

compact_exit=$?

# use highest exit code as global exit code
global_exit=$(( backup_exit > prune_exit ? backup_exit : prune_exit ))
global_exit=$(( compact_exit > global_exit ? compact_exit : global_exit ))

if [ ${global_exit} -eq 0 ]; then
    info "Backup, Prune, and Compact finished successfully"
elif [ ${global_exit} -eq 1 ]; then
    info "Backup, Prune, and/or Compact finished with warnings"
else
    info "Backup, Prune, and/or Compact finished with errors"
fi

exit ${global_exit}
```

---

# date: 2026-03-13 15:51:27

你看一下 functions/os_update.zsh, 这是我自己写的一些更新函数，你看看是否有可以提升的地方。

- 更新 package
- 清理可清理的本地缓存，现在貌似缺乏 conda clean -a
- 保持一个可用的整洁环境。