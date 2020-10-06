
#include "mbl.h"

void mbl_main(boot_info_t* boot_info)
{
    tty_init();
    init_mmap();

    for (;;)
        hlt();
}



MBL_NO_RET void panic(const char* reason){
    tty_set_color(0x1F);
    tty_clear();
    tty_puts("Fatal error: ");
    tty_puts(reason);
    
    for (;;)
        hlt();
}