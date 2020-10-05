#ifndef MMAP_H
#define MMAP_H

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>


typedef struct mmap_entry_t {
    uint64_t base;
    uint64_t size;
    uint64_t type;
} __attribute__((__packed__)) mmap_entry_t;

extern mmap_entry_t* mmap;

#endif // #ifndef MMAP_H
