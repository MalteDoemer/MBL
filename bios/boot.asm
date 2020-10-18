bits 16
section .boot

global start

extern entry
extern sect_cnt

start:
    jmp short skipfat
    nop
    times 90 -($-$$) db 0

    ; the LBA of second stage
    ; will be changed by installer
lba_low dd 0
lba_high dd 0

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

    ; used by lba_mode and chs_mode
    mov si, disk_info

    ; check for LBA extensions
    mov ah, 0x41
    mov bx, 0x55AA
    int 0x13

    jc chs_mode
    cmp bx, 0xAA55
    jne chs_mode
    and cx, 1
    jz chs_mode

lba_mode:
    ; configure the DAP pointed to by si    

    ; set size and zero byte
    mov word [si], 0x1000

    ; set sector count
    mov word [si + 2], sect_cnt

    ; copy low 32-bits of LBA
    mov eax, dword [lba_low]
    mov dword [si + 8], eax

    ; copy high 32-bits of LBA
    mov eax, dword [lba_high]
    mov dword [si + 12], eax

    ; set segment to zero and offset to 0x800
    mov eax, 0x800
    mov dword [si + 4], eax

    ; get the boot drive
    mov dl, byte [drive]

    ; int 0x13 ah = 0x42 to read sectors from disk into memory
    mov ah, 0x42
    int 0x13

    ; on error fall back to chs
    jc chs_mode

    ; go on to the next stage
    jmp entry

chs_mode:






section .bss
mode resb 1
disk_info resb 16
drive resb 1