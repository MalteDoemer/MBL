#ifndef MBL_H
#define MBL_H

#define MBL_PACKED __attribute__((__packed__))

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include "asm.h"
#include "tty.h"
#include "bios/E820.h"

typedef struct boot_info_t {
    uint32_t lba_low;
    uint32_t lba_high;
    uint8_t boot_drive;
} MBL_PACKED boot_info_t;

#endif // #ifndef MBL_H
