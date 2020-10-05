bits 16

[extern mbl_main]
[extern real_to_prot]
[extern prot_to_real]
[extern stack_top]

section .text

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

    ; enable protected mode
    call dword real_to_prot

bits 32
prot_entry:

    ; C requires the direction flag to be cleared
    cld

    ; pass a pointer to the boot info
    mov eax, lba_low
    push eax

    ; call the C entry point
    call mbl_main

hang:
    hlt
    jmp hang 

align 4
lba_low: dd 0
lba_high: dd 0
boot_drive: db 0
