#ifndef MBL_H
#define MBL_H

#define MBL_PACKED __attribute__((__packed__))

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include "stdio.h"
#include "asm.h"
#include "tty.h"

typedef struct boot_info_t {
    uint64_t load_lba;
    uint8_t boot_drive;
} MBL_PACKED boot_info_t;

#endif // #ifndef MBL_H
