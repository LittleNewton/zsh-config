# Function to mount NFS shares
mount_nfs() {
    echo "Mounting NFS shares..."
    sudo mount /mnt/DapuStor_R5100_RAID-Z1/app_data
    sudo mount /mnt/DapuStor_R5100_RAID-Z1/Documents
    sudo mount /mnt/DapuStor_R5100_RAID-Z1/git_repo
    sudo mount /mnt/DapuStor_R5100_RAID-Z1/Software
    sudo mount /mnt/Toshiba_MG06S_RAID-Z1/Downloads
    sudo mount /mnt/WD_HC550_RAID-Z1/Media
    echo "NFS shares mounted."
}

# Function to unmount NFS shares
unmount_nfs() {
    echo "Unmounting NFS shares..."
    sudo umount /mnt/DapuStor_R5100_RAID-Z1/app_data
    sudo umount /mnt/DapuStor_R5100_RAID-Z1/Documents
    sudo umount /mnt/DapuStor_R5100_RAID-Z1/git_repo
    sudo umount /mnt/DapuStor_R5100_RAID-Z1/Software
    sudo umount /mnt/Toshiba_MG06S_RAID-Z1/Downloads
    sudo umount /mnt/WD_HC550_RAID-Z1/Media
    echo "NFS shares unmounted."
}
