org 0x600


; offset | size | description
;      0 |    3 | jump to skip the header
;      3 |    8 | identifier string "mbl  mbl" or in hex 6D 62 6C 20 20 6D 62 6C
;    510 |    2 | Boot signature 0xAA55


stage2.header equ 0x800

start:
    jmp short skip_fat
    nop
    times 90 - ($-$$) db 0
skip_fat:
    cli
    cld
    xor cx, cx
    mov es, cx
    mov ss, cx
    mov ds, cx
    mov si, 0x7C00
    mov di, start
    mov sp, di
    mov ch, 1
    rep stosw
    jmp 0:next

next:
    cmp dl, 0x80
    jb .nolba
    mov ah, 0x41
    mov bx, 0xAA55
    clc
    int 0x13
    jc .nolba
    cmp bx, 0x55AA
    je .load
.nolba:
    mov al, '1'
    jmp error
.load:
    mov si, dap
    mov ah, 0x42
    int 0x13
    cmp word [dap.count], 0
    je .fail
    mov ds, word [dap.segm]
    mov si, word [dap.addr]
    add si, 3
    mov di, id_string
    cmpsd
    jne .fail
    cmpsd
    jne .fail
    add si, 499
    add di, 86
    cmpsw
    jne .fail

    jmp far word [dap.addr]

.fail:
    mov al, '2'
error:
    mov ah, 0x0E
    push ax
    mov si, err_msg
    call print
    pop ax
    int 0x10
    inc si
    call print
    xor ax, ax
    int 0x16
    jmp 0xFFFF:0
print:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp print
.done:
    ret


lba_err_msg: db 'LBA addressing not supported.', 0x00
load_err_msg: db 'Could not load second stage bootloader.', 0x00

err_msg: db 'Boot faild: ', 0x00, 0x0A, 0x0D, 'Press any key to restart...', 0x0A, 0x0D, 0x00

times 416 - ($-$$) db 0
id_string: db 'mbl  mbl'

dap:
    db 0x10
    db 0x00
.count:
    dw 0x0050
.addr:
    dw 0x0800
.segm:
    dw 0x0000
.lba:
    dd 0x00000001
    dd 0x00000000

dd 0
dw 0
times 16 * 4 db 0
dw 0xAA55