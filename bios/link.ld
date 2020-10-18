SECTIONS 
{
    . = 0x600;

    .boot : {
        *(.boot)
    }

    . = 0x800;

    .text : {
        *(.text)
        *(rodata)
    }

    .data : {
        *(.data)
    }

    bss_start = .;
    .bss ALIGN(512) : {
        *(.bss)
    }
    bss_end = .;
}