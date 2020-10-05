bits 16

; [extern mbl_main]
[extern real_to_prot]
[extern prot_to_real]
[extern stack_top]

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

    ; enable protected mode
    call dword real_to_prot

bits 32
prot_entry:
    mov eax, 0x36
    mov word [0xB8000], (0x1F << 8)  | 'F'
    
    call prot_to_real

bits 16
real_again:
    mov ah, 0x0E
    mov al, 'F'
    mov bx, 0x0001
    int 0x10
    
    call dword real_to_prot

bits 32
prot_again:
    mov word [0xB8002], (0x1F << 8)  | 'F'
    jmp $


boot_drive: db 0
lba_low: dd 0
lba_high: dd 0


times 512 - ($-$$) db 0