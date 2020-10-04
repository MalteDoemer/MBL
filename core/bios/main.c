
#include "types.h"

void mbl_main()
{

    volatile uint16_t* vram = (volatile uint16_t*)0xB8000;

    for (int i = 0; i < 25 * 80; i++) {
        vram[i] = 0x1F20;
    }

    for (;;)
        __asm("hlt");
}