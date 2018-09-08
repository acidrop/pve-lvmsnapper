Simple bash script for automating snapshots of LVM Thin volumes (VM) in Proxmox VE.
This can be useful in situations where the VM experiences a disk or filesystem corruption and the only options left is to rollback in a previous version of the VM disk.
This script aims to achieve the same goals, but at more basic level, as the well know zfs-auto-snapshot script for ZFS systems.
Currently the script is taking daily LVM Thin snapshots, but feel free to contribute in adding more functionality, like for example taking hourly,weekly or monthly snapshots as well. Not sure how this will affect LVM Thin performance though, as its design differs from that of the ZFS.
