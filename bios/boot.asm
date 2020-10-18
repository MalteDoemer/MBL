bits 16
cpu 8086
section .boot

global start
extern entry


start:
    ; disable interrupts and clear direction flag
    cli
    cld

    ; clear all segment registers
    xor cx, cx
    mov ds, cx
    mov ss, cx
    mov es, cx

    ; copy from 0x7C00 -> 0x600
    mov di, start
    mov si, 0x7C00

    ; set up the stack at 0x600
    mov sp, di

    ; copy 512 bytes
    mov ch, 1
    rep movsw

    ; clear code segment
    jmp 0:next

next:
    ; enable interrupts
    sti

    mov ah, 0x0E
    mov al, 'Y'
    int 0x10
    jmp $