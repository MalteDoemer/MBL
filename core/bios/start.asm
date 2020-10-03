; total size of core.bin in sectors
[extern sectors]

; the segment where we start loading
[extern load_segment]

section .start

%macro BREAK 1
mov dx, %1
call printhex
jmp $
%endmacro

start:
    ; make a jump to skip the signature
    jmp short skip_sig
    nop

    ; the signature checked by stage 1
    db 'Yeet'

skip_sig:

    ; stage 1 passes the boot drive in dl
    mov byte [boot_drive], dl

    ; bx contains a function pointer
    ; to read from the disk
    mov word [read_func], bx

    ; edx:eax contains the LBA from where this sector was loaded
    mov dword [lba_low], eax
    mov dword [lba_high], edx

    
    mov ah, 0x0E
    mov al, 'F'
    int 0x10

    xor ax, ax
    mov ds, ax
    mov es, ax
    
    mov si, test_msg
    call print
    jmp $


    ; get the amount of sectors to load
    mov cx, sectors
    dec cx

    ; read_func loads at es:di
    mov ax, load_segment
    mov es, ax
    xor di, di

read_loop:
    ; increment LBA by one
    add eax, 1
    adc edx, 0

    ; read one sector from the boot drive
    mov bx, [read_func]
    call bx


    ; carry flag is set on error
    jc disk_err

    ; increment by one sector
    add di, 512

    jnc .cont

    ; if add di, 512 produced a carry we need to adjust es
    mov ax, es
    add ax, 0x1000
    mov es, ax

.cont:
    loop read_loop

jmp $

disk_err:
    push word disk_err_msg
error:
    xor ax, ax
    mov ds, ax
    mov si, error_msg
    call print
    pop si
    call print
    cli
hang:
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


disk_err_msg: db 'disk fail', 0
error_msg: db 'Fatal: '
test_msg: db 'hello', 0

boot_drive: db 0
read_func: dw 0
lba_low: dd 0
lba_high: dd 0

times 512 - ($-$$) db 0
