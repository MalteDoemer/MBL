

if [[ ! -f $FLOPPY ]]; then
    FLOPPY=$HOME/osdev/mbl/floppy.img
fi

dd if=/dev/zero of=$FLOPPY bs=512 count=2880

sudo losetup /dev/loop0 $FLOPPY
sudo mkfs.vfat -R 128 /dev/loop0
sudo losetup -d /dev/loop0