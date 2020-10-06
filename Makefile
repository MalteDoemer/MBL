export MAKE=@make --no-print-directory
export TARGET=bios
export IMAGE=$(abspath disk.img)
export FLOPPY=$(abspath floppy.img)
export INCLUDE=$(abspath include)

export DEFS=

QEMU=qemu-system-i386.exe 
#-S -gdb tcp::9000


.PYHONY: mbr fat clean disk floppy

mbr: 
	$(MAKE) -C boot all DEFS='$(DEFS) MBR'
	$(MAKE) -C core all

fat: 
	$(MAKE) -C boot all DEFS='$(DEFS) FAT'
	$(MAKE) -C core all

disk: mbr
	dd if=boot/bios/boot.bin of=$(IMAGE) bs=440 count=1 conv=notrunc
	dd if=core/bios/core.bin of=$(IMAGE) bs=512 seek=4096 conv=notrunc


	$(QEMU) \
	-m 512 \
	-drive format=raw,file='\\wsl$$\Ubuntu$(IMAGE)',index=0,if=ide \
	-vga std \
	-name "MBL" \
	-monitor stdio \

floppy: fat
	dd if=boot/bios/boot.bin of=$(FLOPPY) bs=1 count=3 conv=notrunc
	dd if=boot/bios/boot.bin of=$(FLOPPY) bs=1 count=422 seek=90 skip=90 conv=notrunc

	dd if=core/bios/core.bin of=$(FLOPPY) bs=1 seek=512 conv=notrunc

	$(QEMU) \
	-m 512 \
	-vga std \
	-drive format=raw,file='\\wsl$$\Ubuntu$(FLOPPY)',index=0,if=floppy \
	-name "MBL" \
	-monitor stdio \

clean:
	$(MAKE) -C boot clean
	$(MAKE) -C core clean