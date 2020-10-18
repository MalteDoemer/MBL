SECTIONS 
{
    . = 0x600;

    .boot : {
        *(.boot)
    }
    . = 0x7B8;

    .part_table : {
        . += 72;
    } = 0

    . = 0x800;

    stage2_start = .;
    .text : {
        *(.text)
        *(rodata)
        . = ALIGN(512);
    } = 0

    .data : {
        *(.data)
        . = ALIGN(512);
    } = 0
    stage2_end = .;

    bss_start = .;
    .bss : {
        *(.bss)
        . = ALIGN(512);
    } = 0
    bss_end = .;


    sect_cnt = (stage2_end - stage2_start) / 512;
}