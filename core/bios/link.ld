SECTIONS 
{
    . = 0x800;

    .text : {
        *(.text)
        *(.rodata)
    }

    .data : {
        *(.data)
    }

    bss_start = .;
    .bss : {
        *(.bss)
    }
    bss_end = .;
}