AS=nasm -f elf32
CC=i686-elf-gcc
LD=i686-elf-ld
OBJCOPY=i686-elf-objcopy


AS_FLAGS=
CC_FLAGS= -O2 -Wall -ffreestanding -nostdlib -std=gnu99 -fno-pic
LD_FLAGS=

OBJS= main.o

.PYHONY: all clean

all: $(OBJS) core.o core.bin

clean:
	rm -f $(OBJS) $(OBJS:.o=.d) core.o core.bin

core.bin: core.o
	$(OBJCOPY) -O binary $< $@

core.o: $(OBJS)
	$(LD) -T link.ld $(LD_FLAGS) $(OBJS) -o $@

%.o: %.asm
	$(AS) -MD $*.d $(AS_FLAGS) $< -o $@

%.o: %.c
	$(CC) -MD -c $(CC_FLAGS) $< -o $@
