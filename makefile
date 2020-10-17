export TARGET=bios
export MAKE=@make --no-print-directory

.PHONY: all tools clean

all:
	$(MAKE) -C boot/$(TARGET) all
	$(MAKE) -C core/$(TARGET) all

tools:
	$(MAKE) -C tools all

clean:
	$(MAKE) -C boot/$(TARGET) clean
	$(MAKE) -C core/$(TARGET) clean
	$(MAKE) -C tools clean
