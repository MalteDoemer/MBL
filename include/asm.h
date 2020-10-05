#ifndef COMMON_H
#define COMMON_H

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

/* Write a byte to a port */
static inline void outb(uint16_t port, uint8_t val) { __asm volatile("outb %0, %1" : : "a"(val), "Nd"(port)); }

/* Write a word to a port */
static inline void outw(uint16_t port, uint16_t val) { __asm volatile("outw %0, %1" : : "a"(val), "Nd"(port)); }

/* Read a byte from a port */
static inline uint8_t inb(uint16_t port)
{
    uint8_t ret;
    __asm volatile("inb %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

/* Read a word from a port */
static inline uint16_t inw(uint16_t port)
{
    uint16_t ret;
    __asm volatile("inw %1, %0" : "=a"(ret) : "Nd"(port));
    return ret;
}

/* Clears the interrupt flag */
static inline void cli() { __asm("cli"); }

/* Sets the interrupt flag */
static inline void sti() { __asm("sti"); }

/* Halts the cpu */
static inline void hlt() { __asm("hlt"); }

#endif // #ifndef COMMON_H
