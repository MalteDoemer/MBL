bits 16
cpu 8086
section .boot

start:
    ; disable interrupts and clear direction flag
    cli
    cld

    ; clear all segment registers
    xor cx, cx
    mov ds, cx
    mov ss, cx
    mov es, cx