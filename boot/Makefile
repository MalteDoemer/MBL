AS=nasm
AS_FLAGS=-f bin

BINS= $(TARGET)/boot.bin

%.bin: %.asm
	$(AS) -MD $(@:.bin=.d) $(AS_FLAGS) $< -o $@

all: $(BINS)

clean:
	rm -f $(BINS) $(BINS:.bin=.d) 

-include $(BINS:.bin=.d)