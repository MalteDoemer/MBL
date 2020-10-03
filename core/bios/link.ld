SECTIONS {

    /* The start address of the second stage */
    . = 0x800;
    start_addr = .;

    .start : {
        *(.start)
    }

    . = 0xA000;

    load_segment = . / 16;

    .text : {
        *(.text)
        *(.rdata)
    }

    .rodata : {
        *(.rodata)
    }

    .data : {
        *(.data)
        . = ALIGN(512);
    }

    end_addr = .;

    size = start_addr - end_addr;
    sectors = size / 512;
}