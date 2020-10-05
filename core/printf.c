
#include <stdint.h>
#include <stddef.h>
#include <stdarg.h>
#include "tty.h"

void printf(const char* fmt, ...)
{
    va_list params;
    va_start(params, fmt);

    while (*fmt) {
        if (*fmt == '%') {
            fmt++;

            switch (*fmt) {
            case '%':
                tty_putc('%');
                break;

            case 'd':
            case 'i':
                tty_putdec(va_arg(params, int));
                break;
            
            case 'x':
            case 'X':
                tty_puthex(va_arg(params, int));
                break;

            case 'c':
                tty_putc(va_arg(params, int)); 
                break;

            case 's':
                tty_puts(va_arg(params, char*));
                break;

            default:
                break;
            }

        } else {
            tty_putc(*fmt);
        }

        fmt++;
    }
}