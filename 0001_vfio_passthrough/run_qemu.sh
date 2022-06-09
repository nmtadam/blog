QEMU=${1}
KERNEL_PATH=${2}
QEMU_IMG=${3}

KERNEL_CMD="root=/dev/sda rw console=tty0 console=ttyS0,115200"

${QEMU} \
-kernel ${KERNEL_PATH} \
--append "${KERNEL_CMD}" \
-enable-kvm -cpu host -smp 16 \
-netdev "user,id=network0,hostfwd=tcp::2022-:22" \
-drive file=${QEMU_IMG},index=0,media=disk,format=raw \
--device "e1000,netdev=network0" \
-m 64G \
-fsdev "local,security_model=passthrough,id=fsdev0,path=/lib/modules" \
-device "virtio-9p-pci,id=fs0,fsdev=fsdev0,mount_tag=modshare" \
-fsdev "local,security_model=passthrough,id=fsdev1,path=/home/nmtadam" \
-device "virtio-9p-pci,id=fs1,fsdev=fsdev1,mount_tag=homeshare" \
-fsdev "local,security_model=passthrough,id=fsdev2,path=/usr/local/lib" \
-device "virtio-9p-pci,id=fs2,fsdev=fsdev2,mount_tag=local_libshare" \
-device vfio-pci,host=db:00.0 \
-netdev "tap,id=priv1,ifname=netqemu0,script=no,downscript=no" \
--device "e1000,netdev=priv1,mac=DE:AD:BE:EF:01:02" \
-serial stdio -display none

