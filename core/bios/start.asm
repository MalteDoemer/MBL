bits 16

; ; entry point of C code
; [extern mbl_main]

; top of the protected mode stack
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

    push dword prot_entry

bits 16
real_to_prot:
    ; clear interrupts
    cli

    ; save our stack
    mov dword [real_stack], esp
   
    ; get the return address from the stack
    pop ebx

    ; data segment must be zero
    xor ax, ax
    mov ds, ax
    mov es, ax

    ; load the gdt 
    lgdt [gdtdesc32]

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

    ; get the protected mode stack
    mov esp, dword [prot_stack]
    mov ebp, esp

    ; store the return address on the stack
    mov dword [esp], ebx

    ; switch IDT's
    lidt [prot_idtdesc]

    ; return on prot mode stack
    ret

bits 32
prot_entry:
    mov eax, 0x36
    lidt [prot_idtdesc] 
    mov word [0xB8000], (0x1F << 8)  | 'F'
    jmp $


boot_drive: db 0
lba_low: dd 0
lba_high: dd 0

prot_stack: dd stack_top

real_stack: dd 0

align 4
gdt32:

null32: equ $ - gdt32
    dq 0

code32: equ $ - gdt32
    dw 0xFFFF
    dw 0
    db 0
    db 10011010b
    db 11001111b
    db 0

data32: equ $ - gdt32
    dw 0xFFFF
    dw 0
    db 0
    db 10010010b
    db 11001111b
    db 0

code16: equ $ - gdt32
    dw 0xFFFF
    dw 0
    db 0
    db 10011010b
    db 00001111b
    db 0
    
data16: equ $ - gdt32
    dw 0xFFFF
    dw 0
    db 0
    db 10010010b
    db 00001111b
    db 0


align 16
[global gdtdesc32]
gdtdesc32:
    dw 0x27
    dd gdt32


[global real_idtdesc]
real_idtdesc:
    dw 0x3FF
    dd 0

[global prot_idtdesc]
prot_idtdesc:
    dw 0
    dd 0




; gdt16:
; null16: equ $ - gdt16
    ; dq 0

; code16: equ $ - gdt16
;     dw 0xFFFF
;     dw 0
;     db 0
;     db 10011010b
;     db 00001111b
;     db 0
    
; data16: equ $ - gdt16
;     dw 0xFFFF
;     dw 0
;     db 0
;     db 10010010b
;     db 00001111b
;     db 0


; [global gdtdesc16]
; gdtdesc16:
;     dw $ - gdt16 - 1
;     dd gdt16

times 512 - ($-$$) db 0