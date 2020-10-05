SECTIONS {

    /* The start address of the second stage */
    . = 0x800;
    start_addr = .;

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
    stack_bottom = .;
    . = . + 0x1000;
    stack_top = .;

    mmap = .;
    . = . + 0x300;
    mmap_buf_end = .;
    

    size = end_addr - start_addr;
    sectors = size / 512;
}