#ifndef STRING_H
#define STRING_H

#include <stddef.h>

/* Copy N bytes of SRC to DEST.  */
void* memcpy(void* dest, void* src, size_t n);

/* Set N bytes of S to C.  */
void* memset(void* dest, int c, size_t n);

/* Compare N bytes of S1 and S2.  */
int memcmp(const void* s1, const void* s2, size_t n);

/* Search N bytes of S for C.  */
void* memchr(void* src, int c, size_t n);

/* Copy SRC to DEST.  */
char* strcpy(char* dest, const char* src);

/* Copy no more than N characters of SRC to DEST.  */
char* strncpy(char* dest, const char* src, size_t n);

/* Append SRC onto DEST.  */
char* strcat(char* dest, const char* src);

/* Append no more than N characters from SRC onto DEST.  */
char* strncat(char* dest, const char* src, size_t n);

/* Compare S1 and S2.  */
int strcmp(const char* s1, const char* s2);

/* Compare N characters of S1 and S2.  */
int strncmp(const char* s1, const char* s2, size_t n);

/* Duplicate S, returning an identical malloc'd string.  */
char* strdup(const char* src);

/* Return a malloc'd copy of at most N bytes of STRING.  The
   resultant string is terminated even if no null terminator
   appears before STRING[N].  */
char* strndup(const char* string, size_t n);

/* Find the first occurrence of C in S.  */
char* strchr(const char* s, int c);

/* Find the last occurrence of C in S.  */
char* strrchr(const char* s, int c);

/* Find the first occurrence of NEEDLE in HAYSTACK.  */
char* strstr(const char* haystack, const char* needle);

/* Divide S into tokens separated by characters in DELIM.  */
char* strtok(char* s, const char* delim);

/* Divide S into tokens separated by characters in DELIM.  Information
   passed between calls are stored in SAVE_PTR.  */
char* strtok_r(char* s, const char* delim, char** save_ptr);

/* Return the length of S.  */
size_t strlen(const char * s);

/* Find the length of STRING, but scan at most MAXLEN characters.
   If no '\0' terminator is found in that many characters, return MAXLEN.  */
size_t strnlen(const char * s, size_t maxlen);

#endif // #ifndef STRING_H
