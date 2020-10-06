#include "mbl.h"
#include "bios/E820.h"

mmap_entry_t* mmap;
uint32_t mmap_count;

void init_mmap()
{
    mmap = &mmap_start;
    mmap_count = get_e820_map();

    /* check if we were sucessful */
    if (mmap_count == 0) {
        panic("Unable to get E820 memory map.");
    }

#ifdef PRINT_MMAP
    tty_puts("Count: ");
    tty_putdec(mmap_count);
    tty_putc('\n');
    tty_puts("Base Address       | Length             | Type\n");

    for (int i = 0; i < mmap_count; i++) {
        tty_puthex(mmap[i].base);
        tty_puts(" | ");
        tty_puthex(mmap[i].size);
        tty_puts(" | ");
        tty_putdec(mmap[i].type);
        tty_putc('\n');
    }
#endif
}
