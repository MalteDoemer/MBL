#!/bin/bash

if [[ ! -f $IMAGE ]]; then
    IMAGE=$HOME/osdev/mbl/disk.img
fi

dd if=/dev/zero of=$IMAGE count=1 bs=34M

printf "g\nn\n1\n\n+1M\nt\n4\nw\n" | fdisk $IMAGE 
printf "n\n2\n\n\np\nw\n" | fdisk $IMAGE 

sudo losetup -o $[4096*512] --sizelimit $[65503*512] /dev/loop0 $IMAGE
sudo mkfs.vfat /dev/loop0
sudo losetup -d /dev/loop0