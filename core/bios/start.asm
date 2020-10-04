bits 16

; total size of core.bin in sectors
[extern sectors]

; the segment where we start loading
[extern load_segment]

; entry point of C code
[extern mbl_main]

section .start

start:
    ; stage 1 passes the boot drive in dl
    mov byte [boot_drive], dl

    ; bx contains a function pointer
    ; to read from the disk
    mov word [read_func], bx


    ; the LBA is passed via the stack
    pop edx
    pop eax

    ; save the LBA
    mov dword [lba_low], eax
    mov dword [lba_high], edx

    ; get the address where we are loading
    mov bx, load_segment
    mov es, bx
    xor di, di

    ; load the rest of core.bin
    mov cx, sectors
    dec cx

read_loop:

    ; increment the LBA
    add eax, 1
    adc edx, 0

    ; read one sector from the boot drive
    call word [read_func]

    ; carry flag is set on error
    jc disk_error

    ; increment the pointer
    add di, 512

    ; if di overflowed we need to increment es
    jnc continue

    mov bx, es
    add bx, 0x1000
    mov es, bx
    jmp continue

continue:
    loop read_loop

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

    ; push all arguments on the stack
    mov ah, 0
    mov al, byte [boot_drive]
    push ax

    mov eax, dword [lba_high]
    push eax
    
    mov eax, dword [lba_low]
    push eax
    
    jmp mbl_main

disk_error:
    push word disk_error_msg
error:
    mov si, error_msg
    call print
    pop si
    call print
hang:
    cli
    hlt
    jmp hang

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

disk_error_msg: db 'disk fail', 0
error_msg: db 'Fatal: ', 0

boot_drive: db 0
read_func: dw 0
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