
#include "bios/mbl.h"

void mbl_main(boot_info_t* boot_info)
{
    tty_init();

    for (;;)
        hlt();
}