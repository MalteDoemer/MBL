; top of protmode stack
[extern stack_top]


[bits 16]
[global real_to_prot]
real_to_prot:
    ; clear interrupts
    cli

    ; save our stack
    mov dword [real_esp], esp

    ; get the return address from the stack
    pop eax
    mov dword [return_addr], eax

    ; data segment should be zero
    xor ax, ax
    mov ds, ax

    ; load the gdt
    lgdt [gdtdesc]

    ; enable protected mode
    mov eax, cr0
    or al, 1
    mov cr0, eax

    ; reload the code segment
    jmp code32:reload_seg

[bits 32]
reload_seg:
    ; reload all data segments
    mov ax, data32
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; get the protected mode stack
    mov esp, dword [prot_esp]
    mov ebp, dword [prot_ebp]

    ; store the return address on the stack
    mov eax, dword [return_addr]
    mov dword [esp], eax

    ; switch IDT's
    sidt [real_idtdesc]
    lidt [prot_idtdesc]

    ; return on prot mode stack
    ret

[bits 32]
[global prot_to_real]
prot_to_real:
    ; clear interrupts
    cli

    ; save the prot mode stack
    mov dword [prot_esp], esp
    mov dword [prot_ebp], ebp

    ; get the return address
    pop eax
    mov dword [return_addr], eax

    ; just in case load the GDT
    lgdt [gdtdesc]

    ; switch IDT's
    sidt [prot_idtdesc]
    lidt [real_idtdesc]

    ; load 16-bit data segments
    mov ax, data16
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; go into 16-bit protected mode
    jmp code16:prot_16

[bits 16]
prot_16:
    
    ; disable protected mode
    mov eax, cr0
    and al, ~1
    mov cr0, eax

    jmp 0:real_mode

real_mode:
    ; clear all segment registers
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; set the real mode stack
    mov esp, dword [real_esp]

    ; store the return address
    mov eax, dword [return_addr]
    mov dword [esp], eax

    ; enable interrupts
    sti

    ; return on real mode stack
    retd

prot_esp: dd stack_top
prot_ebp: dd stack_top

real_esp: dd 0
return_addr: dd 0

align 4
[global gdtdesc]
gdtdesc:
    dw 0x27
    dd gdt

[global prot_idtdesc]
prot_idtdesc:
    dw 0
    dd 0

[global real_idtdesc]
real_idtdesc:
    dw 0
    dd 0


align 4
gdt:

null32: equ $ - gdt
    dq 0

code32: equ $ - gdt
    dw 0xFFFF
    dw 0
    db 0
    db 10011010b
    db 11001111b
    db 0

data32: equ $ - gdt
    dw 0xFFFF
    dw 0
    db 0
    db 10010010b
    db 11001111b
    db 0

code16: equ $ - gdt
    dw 0xFFFF
    dw 0
    db 0
    db 10011010b
    db 00001111b
    db 0

data16: equ $ - gdt
    dw 0xFFFF
    dw 0
    db 0
    db 10010010b
    db 00001111b
    db 0
