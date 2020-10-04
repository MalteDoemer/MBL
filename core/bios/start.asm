bits 16

; ; entry point of C code
; [extern mbl_main]

section .start

start:
    ; the boot drive is passed via the stack
    pop dx
    mov byte [boot_drive], dl

    ; LBA is also passed via the stack
    pop edx
    pop eax

    ; save the LBA
    mov dword [lba_low], eax
    mov dword [lba_high], edx

    mov ah, 0x0E
    mov al, 'F'
    int 0x10

    jmp $


switch_prot:
    ; make sure es is zero
    xor ax, ax
    mov es, ax

    ; clear interrupts
    cli

    ; load the gdt 
    lgdt [GDTR32]

    ; enable protected mode
    mov eax, cr0
    or al, 1
    mov cr0, eax

    ; reload the code segment
    jmp 0x08:reload_seg
reload_seg:
    ; reload all data segments
    mov ax, 0x10
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    jmp $

print:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    mov bx, 0x0001
    int 0x10
    jmp print
.done:
    ret


boot_drive: db 0
lba_low: dd 0
lba_high: dd 0

align 8
GDT32:
    dq 0

    dw 0xFFFF
    dw 0
    db 0
    db 10011010b
    db 11001111b
    db 0

    dw 0xFFFF
    dw 0
    db 0
    db 10010010b
    db 11001111b
    db 0

GDTR32:
    dw $ - GDT32 - 1
    dd GDT32

times 512 - ($-$$) db 0