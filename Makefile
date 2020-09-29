
ARCH?=x86_64
ASM?=nasm
ASM_FLAGS?= -f bin

STAGE1=bin/$(ARCH)/stage1.bin
STAGE2=bin/$(ARCH)/stage2.bin
MKBOOT=bin/mkboot-$(ARCH)

disk.img: $(MKBOOT)
	$(MKBOOT) $@

$(MKBOOT): src/mkboot.c $(STAGE1)
	ld -r -b binary $(STAGE1) -o $(STAGE1:.bin=.o)
	gcc -D ARCH=$(ARCH) $< $(STAGE1:.bin=.o) -o $@

bin/%.bin: src/%.asm
	mkdir -p $(dir $@)
	$(ASM) $(ASM_FLAGS) $< -o $@

.PHONY: clean format run

run: disk.img
	qemu-system-x86_64.exe -m 512 -drive format=raw,file='\\wsl$$\Ubuntu$(abspath disk.img)' -serial stdio

format:
	dd if=/dev/zero of=disk.img bs=1048576 count=16
	mkdosfs disk.img

clean:
	rm -f $(STAGE1) $(STAGE2) $(MKBOOT)