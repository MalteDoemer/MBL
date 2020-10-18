export TARGET=bios
export MAKE=@make --no-print-directory
export DEST=$(abspath dest/$(TARGET))

.PHONY: all tools clean

all:
	$(MAKE) -C $(TARGET) all

install:
	sudo mkdir -p $(DEST)
	$(MAKE) -C $(TARGET) install

tools:
	$(MAKE) -C tools all

clean:
	$(MAKE) -C $(TARGET) clean
	$(MAKE) -C tools clean
