#ifndef MMAP_H
#define MMAP_H

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>


typedef struct mmap_entry_t {
    uint64_t base;
    uint64_t size;
    uint8_t type;
    uint8_t res1;
    uint16_t res2;
    uint32_t res3;
} __attribute__((__packed__)) mmap_entry_t;


extern mmap_entry_t mmap_start;
extern mmap_entry_t mmap_end;

extern mmap_entry_t* mmap;
extern uint32_t mmap_count;

void init_mmap();

#endif // #ifndef MMAP_H
