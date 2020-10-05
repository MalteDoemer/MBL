#ifndef E820_H
#define E820_H

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include "mmap.h"

uint32_t get_e820_map();

#endif // #ifndef E820_H
