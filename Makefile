
ARCH?=x86_64
ASM?=nasm
ASM_FLAGS?= -f bin

STAGE1=bin/$(ARCH)/stage1.bin
STAGE2=bin/$(ARCH)/stage2.bin
MKBOOT=bin/$(ARCH)/mkboot

$(MKBOOT): src/mkboot.c $(STAGE1)
	ld -r -b binary $(STAGE1) -o $(STAGE1:.bin=.o)
	gcc -D ARCH=$(ARCH) $< $(STAGE1:.bin=.o) -o $@

bin/%.bin: src/%.asm
	mkdir -p $(dir $@)
	$(ASM) $(ASM_FLAGS) $< -o $@

.PHONY: all clean

all: $(STAGE1) $(STAGE2)

clean:
	rm -f $(STAGE1) $(STAGE2) $(MKBOOT)