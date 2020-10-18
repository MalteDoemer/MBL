bits 16
section .text

global entry

entry:
    mov ah, 0x0E
    mov al, 'F'
    int 0x10
    jmp $