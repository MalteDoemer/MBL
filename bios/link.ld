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
        . = ALIGN(512);
    }

    .data : {
        *(.data)
        . = ALIGN(512);
    }
    stage2_end = .;

    bss_start = .;
    .bss ALIGN(512) : {
        *(.bss)
    }
    bss_end = .;


    sect_cnt = (stage2_end - stage2_start) / 512;
}