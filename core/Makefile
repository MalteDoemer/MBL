AS=nasm
CC=i686-elf-gcc
LD=i686-elf-ld
OBJCOPY=i686-elf-objcopy

AS_FLAGS= -f elf32
CFLAGS= -m32 -ffreestanding -fno-PIE -nostartfiles -nostdlib -std=c99 -Wno-packed-bitfield-compat -I $(INCLUDE)

include $(TARGET)/make.config

GENERIC_OBJS=

OBJS=$(TARGET_OBJS) $(GENERIC_OBJS)

$(TARGET)/core.bin: $(TARGET)/core.o
	$(OBJCOPY) -O binary $< $@

$(TARGET)/core.o: $(OBJS)
	$(LD) -T $(TARGET)/link.ld $(OBJS) -o $@

%.o: %.asm
	$(AS) -MD $(@:.o=.d) $(AS_FLAGS) $< -o $@

%.o: %.c
	$(CC) -MD -c $(CFLAGS) $< -o $@

all: $(OBJS) $(TARGET)/core.o $(TARGET)/core.bin

clean:
	rm -f $(OBJS) $(OBJS:.o=.d) $(TARGET)/core.o $(TARGET)/core.bin

-include $(OBJS:.o=.d)
