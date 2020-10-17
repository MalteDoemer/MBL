AS=nasm


BINS=gpt.bin mbr.bin

all: $(BINS)

clean:
	rm -f $(BINS) $(BINS:.bin=.d)

%.bin: %.asm
	$(AS) -f bin -MD $(@:.bin=.d) $< -o $@

-include $(BINS:.bin=.d)