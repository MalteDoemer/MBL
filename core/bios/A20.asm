[extern prot_to_real]
[extern real_to_prot]


[bits 32]
[global enableA20]
enableA20:
    ; check if A20 is already enabled
    call checkA20
    test al, al
    jz try_bios
    ret

try_bios:
    ; try with int 0x15 ax = 0x2401

    ; we need real mode
    call prot_to_real

    bits 16
    mov ax, 0x2401
    int 0x15

    ; go back to prot mode
    call dword real_to_prot
    bits 32

    ; check if bios was sucessful
    call checkA20
    test al, al
    jz try_keyboard
    ret

try_keyboard:

    ; try with keyboard controller
    call a20wait
    mov al, 0xAD
    out 0x64, al

    call a20wait
    mov al, 0xD0
    out 0x64, al

    call a20wait2
    in al, 0x60
    push eax

    call a20wait
    mov al, 0xD1
    out 0x64, al

    call a20wait
    pop eax
    or al, 2
    out 0x60, al

    call a20wait
    mov al,0xAE
    out 0x64,al

    call a20wait
    
    ; check if the keyboard method was sucessful
    call checkA20
    test al, al
    jz try_control_port

    ret

try_control_port:

    ; try with system control port
    in al, 0x92
    and al, ~3
    or al, 2
    out 0x92, al

    call checkA20
    test al, al
    jz a20_fail

    ret

a20_fail:
    jmp $

a20wait:
    in al, 0x64
    test al, 2
    jnz a20wait
    ret

a20wait2:
    in al, 0x64
    test al, 1
    jnz a20wait2
    ret

checkA20:
    mov edi, 0x112345
    mov esi, 0x012345

    mov dword [edi], edi
    mov dword [esi], esi

    cmpsd
    je .off

    mov al, 1
    ret

    .off:
    mov al, 0
    ret
