#ifndef TTY_H
#define TTY_H

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

void tty_init();
void tty_clear();
void tty_set_color(uint8_t color);
void tty_putc(char c);
void tty_puts(const char* s);
void tty_puthex(uint64_t n);
void tty_putdec(int32_t n);
void tty_copy(const char* data, size_t size);

#endif // #ifndef TTY_H
