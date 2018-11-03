==Simple bash script for automating snapshots of LVM Thin volumes (VM) in Proxmox VE.

This can be useful in situations where the VM experiences a disk or filesystem corruption and the only option left is to rollback to a previous version of the VM disk.
Note that, as the snapshots are generated at the LVM level (not QEMU), the consistency of the data inside the virtual machine
is NOT guaranteed (i.e databases).
This script aims to achieve the same goals, but at more basic level, as the well know zfs-auto-snapshot script for ZFS systems.
Currently the script is getting only daily LVM Thin snapshots, but feel free to contribute in adding more functionality, like for example getting hourly,weekly or monthly snapshots as well. Not sure how this will affect LVM Thin performance though, as its design differs from that of the ZFS.
