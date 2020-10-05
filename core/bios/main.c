
#include "bios/mbl.h"

void mbl_main(boot_info_t* boot_info)
{
    tty_init();

    uint32_t count = get_e820_map();

    tty_puts("Count: ");
    tty_putdec(count);
    tty_putc('\n');
    tty_puts("Base Address       | Length             | Type\n");

    for (int i = 0; i < count; i++) {
        tty_puthex(mmap[i].base);
        tty_puts(" | ");
        tty_puthex(mmap[i].size);
        tty_puts(" | ");
        tty_putdec(mmap[i].type);
        tty_putc('\n');
    }

    for (;;)
        hlt();
}