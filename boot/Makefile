AS=nasm
AS_FLAGS=-f bin

BINS= $(TARGET)/boot.bin
NASM_DEFS=$(patsubst %,-D %,$(DEFS))

%.bin: %.asm
	$(AS) -MD $(@:.bin=.d) $(AS_FLAGS) $(NASM_DEFS) $< -o $@

all: $(BINS)

clean:
	rm -f $(BINS) $(BINS:.bin=.d) 

-include $(BINS:.bin=.d)