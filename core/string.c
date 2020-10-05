#include "string.h"

void* memcpy(void* dest, void* src, size_t n)
{
    for (unsigned char* d = dest; n--; dest++, src++) {
        *d = *(unsigned char*)src;
    }
    return dest;
}

void* memset(void* dest, int c, size_t n)
{
    for (unsigned char* d = dest; n--; d++) {
        *d = (unsigned char)c;
    }

    return dest;
}

int memcmp(const void* s1, const void* s2, size_t n)
{
    while (n--) {
        if (*(unsigned char*)s1 != *(unsigned char*)s2) {
            return (*(unsigned char*)s1) - (*(unsigned char*)s2);
        }
        s1++;
        s2++;
    }
    return 0;
}

void* memchr(void* src, int c, size_t n)
{

    while (n) {
        if (*(unsigned char*)src == c) {
            return src;
        }
        src++;
    }
    return NULL;
}

char* strcpy(char* dest, const char* src);
char* strncpy(char* dest, const char* src, size_t n);
char* strcat(char* dest, const char* src);
char* strncat(char* dest, const char* src, size_t n);
int strcmp(const char* s1, const char* s2);
int strncmp(const char* s1, const char* s2, size_t n);
char* strdup(const char* src);
char* strndup(const char* string, size_t n);
char* strchr(const char* s, int c);
char* strrchr(const char* s, int c);
char* strstr(const char* haystack, const char* needle);
char* strtok(char* s, const char* delim);
char* strtok_r(char* s, const char* delim, char** save_ptr);

size_t strlen(const char* s)
{
    const char* t;
    for (t = s; *s; s++)
        ;
    return (size_t)(t - s);
}

size_t strnlen(const char* s, size_t maxlen)
{
    const char* t;
    for (t = s; *s && maxlen--; s++)
        ;
    return (size_t)(t - s);
}