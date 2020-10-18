export TARGET=bios
export MAKE=@make --no-print-directory
export DEST=/usr/lib/mbl/bios

IMAGE=$(abspath disk.img)

.PHONY: all tools clean format run

all:
	$(MAKE) -C $(TARGET) all

install:
	sudo mkdir -p $(DEST)
	$(MAKE) -C $(TARGET) install

tools:
	$(MAKE) -C tools all

format:
	dd if=/dev/zero of=$(IMAGE) bs=512 count=131072
	printf "o\nn\np\n1\n\n\na\np\nw\n" | fdisk $(IMAGE) 
	sudo losetup -o 1048576 /dev/loop3 $(IMAGE)
	sudo mkfs.fat -h 2048 /dev/loop3
	sudo losetup -d /dev/loop3

run: all tools install
	tools/mbl-install $(IMAGE)
	qemu-system-x86_64.exe \
	-drive format=raw,file='\\wsl$$\Ubuntu$(IMAGE)',if=ide \
	-m 512 \
	-d cpu_reset \
	-name "MBL" \
	-monitor stdio \

# -drive format=raw,file='\\wsl$$\Ubuntu$(IMAGE)',if=ide
#-blockdev driver=file,node-name=disk,filename='\\wsl$$\Ubuntu$(IMAGE)' -device ide-hd,drive=disk,physical_block_size=1024 \
	

clean:
	$(MAKE) -C $(TARGET) clean
	$(MAKE) -C tools clean
