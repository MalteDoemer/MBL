SECTIONS 
{
    . = 0x600;

    .boot : {
        *(.boot)
    }
    . = 0x7B8;

    . = 0x800;

    stage2_start = .;
    .text : {
        *(.text)
        *(rodata)
    }

    .data : {
        *(.data)
    }
    stage2_end = .;

    bss_start = .;
    .bss ALIGN(512) : {
        *(.bss)
    }
    bss_end = .;


    stage2_size = stage2_end - stage2_start;
    stage2_sectors = stage2_size / 512;
}