AS=nasm -f elf32
CC=i686-elf-gcc
LD=i686-elf-ld
OBJCOPY=i686-elf-objcopy

AS_FLAGS=
CC_FLAGS= -O2 -ffreestanding -nostdlib -std=c99 
LD_FLAGS=

OBJS= \
boot.o \
entry.o \

all: $(OBJS) core.o core.bin boot.bin

install:
	sudo cp core.bin boot.bin $(DEST)

clean:
	rm -f $(OBJS) core.bin boot.bin core.o

boot.bin: core.o
	$(OBJCOPY) -j .boot -O binary $< $@

core.bin: core.o
	$(OBJCOPY) -R .boot -O binary $< $@

core.o: $(OBJS)
	$(LD) -T link.ld $(LD_FLAGS) $(OBJS) -o $@

%.o: %.asm
	$(AS) -MD $*.d $(AS_FLAGS) $< -o $@

%.o: %.c
	$(CC) -MD -c $(CC_FLAGS) $< -o $@

-include $(OBJS:.o=.d)