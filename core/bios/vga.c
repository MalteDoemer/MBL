#include "bios/mbl.h"

static const uint32_t width = 80;
static const uint32_t height = 25;

static volatile uint16_t* const vmem = (volatile uint16_t* const)0xB8000;

static uint32_t cursor = 0;
static uint8_t attrs = 0x1F;

extern void bios_video_mode(uint8_t mode);
static uint8_t get_vga_char(char c);
static void update_cursor();
static void check_scroll();

void tty_init()
{
    bios_video_mode(3);
    tty_clear();
}

void tty_clear()
{
    cursor = 0;
    for (uint32_t i = 0; i < width * height; i++) {
        vmem[i] = (attrs << 8) | ' ';
    }

    update_cursor();
}

void tty_set_color(uint8_t color)
{
    attrs = color;
}

void tty_putc(char c)
{
    if (c == '\b' && cursor) {
        cursor--;
        vmem[cursor] = (attrs << 8) | ' ';
    } else if (c == '\t') {
        cursor = (cursor + 4) & ~(4 - 1);
    } else if (c == '\r') {
        cursor = (cursor / width) * height;
    } else if (c == '\n') {
        cursor += width;
        cursor = (cursor / width) * width;
    } else if (c >= ' ') {
        vmem[cursor] = (attrs << 8) | get_vga_char(c);
        cursor++;
    }

    update_cursor();
    check_scroll();
}

void tty_puts(const char* str)
{
    while (*str) {
        tty_putc(*str);
        str++;
    }
}

void tty_puthex(uint32_t n)
{
    static const char* format = "0123456789ABCDEF";
    tty_puts("0x");

    for (int i = 28; i > -1; i-=4){
        tty_putc(format[(n >> i) & 0xF]);
    }
}

void tty_putdec(int n){
    if (n == 0){
        tty_putc('0');
        return;
    }

    if (n < 0){
        tty_putc('-');
        n *= -1;
    }

    char buf[16];

    int end = 0;

    while (n != 0)
    {
        buf[end++] = '0' + (n % 10);
        n /= 10;
    }
    
    while (end){
        tty_putc(buf[end--]);
    }
}

void tty_copy(const char* data, size_t size)
{
    if (size > width * height)
        size = width * height;

    for (size_t i = 0; i < size; i++) {
        vmem[i] = data[i];
    }
}

static uint8_t get_vga_char(char c)
{
    static const uint8_t ansi_to_vga[256] = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        ' ', '!', '"', '#', '$', '%', '&', '\'', '(', ')', '*', '+', ',', '-', '.', '/', '0', '1', '2', '3', '4', '5', '6',
        '7', '8', '9', ':', ';', '<', '=', '>', '?', '@', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
        'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '[', '\\', ']', '^', '_', '`', 'a', 'b', 'c', 'd',
        'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '{',
        '|', '}', '~', 0,
        0,   // €
        0,   //
        0,   // ‚
        159, // ƒ
        0,   // „
        0,   // …
        0,   // †
        0,   // ‡
        0,   // ˆ
        0,   // ‰
        0,   // Š
        0,   // ‹
        0,   // Œ
        0,   //
        0,   // Ž
        0,   //
        0,   //
        0,   // ‘
        0,   // ’
        0,   // “
        0,   // ”
        0,   // •
        0,   // –
        0,   // —
        0,   // ˜
        0,   // ™
        0,   // š
        0,   // ›
        0,   // œ
        0,   //
        0,   // ž
        0,   // Ÿ
        0,   //
        173, // ¡
        155, // ¢
        156, // £
        0,   // ¤
        157, // ¥
        '|', // ¦
        22,  // §
        0,   // ¨
        0,   // ©
        166, // ª
        174, // «
        170, // ¬
        0,   // ­
        0,   // ®
        0,   // ¯
        248, // °
        241, // ±
        254, // ²
        0,   // ³
        0,   // ´
        230, // µ
        0,   // ¶
        249, // ·
        0,   // ¸
        0,   // ¹
        167, // º
        175, // »
        172, // ¼
        171, // ½
        0,   // ¾
        168, // ¿
        0,   // À
        0,   // Á
        0,   // Â
        0,   // Ã
        142, // Ä
        143, // Å
        146, // Æ
        128, // Ç
        0,   // È
        144, // É
        0,   // Ê
        0,   // Ë
        0,   // Ì
        0,   // Í
        0,   // Î
        0,   // Ï
        0,   // Ð
        165, // Ñ
        0,   // Ò
        0,   // Ó
        0,   // Ô
        0,   // Õ
        153, // Ö
        0,   // ×
        0,   // Ø
        0,   // Ù
        0,   // Ú
        0,   // Û
        154, // Ü
        0,   // Ý
        0,   // Þ
        0,   // ß
        133, // à
        160, // á
        131, // â
        0,   // ã
        132, // ä
        134, // å
        0,   // æ
        135, // ç
        138, // è
        130, // é
        136, // ê
        137, // ë
        141, // ì
        161, // í
        140, // î
        139, // ï
        0,   // ð
        164, // ñ
        149, // ò
        162, // ó
        147, // ô
        0,   // õ
        148, // ö
        246, // ÷
        237, // ø
        151, // ù
        163, // ú
        150, // û
        129, // ü
        0,   // ý
        0,   // þ
        152, // ÿ
    };

    return ansi_to_vga[(uint8_t)c];
}

static void update_cursor()
{
    outb(0x3D4, 14);
    outb(0x3D5, cursor >> 8);
    outb(0x3D4, 15);
    outb(0x3D5, cursor);
}

static void check_scroll()
{
    if (cursor >= width * height) {
        for (uint32_t i = 0; i < width * (height - 1); i++) {
            vmem[i] = vmem[i + width];
        }

        for (uint32_t i = width * (height - 1); i < width * height; i++) {
            vmem[i] = (attrs << 8) | ' ';
        }

        cursor = width * (height - 1);
        update_cursor();
    }
}
