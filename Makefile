export MAKE=@make --no-print-directory
export IMAGE=$(abspath disk.img)
export INCLUDE=$(abspath include)
export TARGET=bios

.PYHONY: all clean bios

all:
	$(MAKE) -C boot all
	$(MAKE) -C core all

clean:
	$(MAKE) -C boot clean
	$(MAKE) -C core clean

bios: all
	dd if=boot/bios/boot.bin of=$(IMAGE) bs=1 count=3 conv=notrunc
	dd if=boot/bios/boot.bin of=$(IMAGE) bs=1 seek=90 skip=90 count=350 conv=notrunc
	# TODO replace LBA in boot/bios/boot.bin
	dd if=core/bios/core.bin of=$(IMAGE) bs=512 seek=4096 conv=notrunc


	qemu-system-x86_64.exe \
	-m 512 \
	-drive format=raw,file='\\wsl$$\Ubuntu$(IMAGE)',if=ide \
	-name "MBL" \
	-monitor stdio \

