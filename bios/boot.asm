bits 16
cpu 8086
section .boot

global start

extern entry
extern stage2_sectors


start:
    jmp short skipfat
    nop
    times 90 -($-$$) db 0

skipfat:
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

    ; save boot drive
    mov byte [drive], dl



section .bss
    drive resb 1