#ifndef MBL_H
#define MBL_H

#define MBL_PACKED __attribute__((__packed__))
#define MBL_NO_RET __attribute__((__noreturn__))

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>
#include "asm.h"
#include "tty.h"
#include "mmap.h"

typedef struct boot_info_t {
    uint32_t lba_low;
    uint32_t lba_high;
    uint8_t boot_drive;
} MBL_PACKED boot_info_t;

void mbl_main(boot_info_t* boot_info);

MBL_NO_RET void panic(const char* reason);

#endif // #ifndef MBL_H
