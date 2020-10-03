org 0x600

%define KERNEL_ADDR 0x800

start:
    ; we might be on a FAT partition 
    ; so we need to skip the first 90 bytes
    jmp short skip_bpb
    times 90 - ($-$$) nop

skip_bpb:
    ; clear interrupts and direction flag
    cli
    cld

    ; clear all segment registers
    xor cx, cx
    mov ss, cx
    mov ds, cx
    mov es, cx
    mov fs, cx
    mov gs, cx

    ; relocate us from 0x7C00 to 0x600
    ; set up a tiny stack at 0x600
    mov si, 0x7C00
    mov di, 0x600
    mov sp, di
    mov ch, 1
    rep movsw

    ; correct code segment
    ; because we might be at 0x7C0:0x00
    jmp 0:next

next:
    ; enable interrupts again
    sti

    ; save the boot drive
    mov byte [boot_drive], dl

    ; check for LBA addressing
    mov ah, 0x41
    mov bx, 0x55AA
    int 0x13

    ; dl may be clobbered
    mov dl, byte [boot_drive]

    ; if carry flag is set LBA isn't supported
    jc chs_mode

    ; bx must be 0xAA55
    cmp bx, 0xAA55
    jne chs_mode

    ; cx bit #1 must be set
    and cx, 1
    jz chs_mode


    ; load the LBA into edx:eax
    mov eax, dword [dap.lba_low]
    mov edx, dword [dap.lba_high]

    ; load the kernel address
    mov di, KERNEL_ADDR

    ; read one sector from the disk
    call lba_read
   
    ; carry flag is set on error
    jc disk_err

    ; check for our signature
    mov eax, 'Yeet'
    cmp dword [di + 3], eax
    jne sig_fail

    ; we will pass the second stage a pointer to
    ; the appropriate read function
    mov bx, lba_read

    ; pass the boot drive in dl
    mov dl, byte [boot_drive]  

    jmp KERNEL_ADDR

chs_mode:
    jmp $


sig_fail:
    push word sig_fail_msg
    jmp error
disk_err:
    push word disk_err_msg
error:
    mov si, error_msg
    call print
    pop si
    call print
    cli
hang:
    hlt
    jmp hang


print_loop:
    mov ah, 0x0E
    mov bx, 0x0001
    int 0x10
print:
    lodsb
    cmp al, 0
    jne print_loop
    ret


; IN: edx:eax LBA;  es:di = buffer
; OUT: carry flag set on error
chs_read:
    ; not implemented
    stc
    ret

; IN: edx:eax LBA;  es:di = buffer
; OUT: carry flag set on error
lba_read:
    ; presreve all registers
    pusha

    ; let si to point to the DAP
    mov si, dap

    ; store the LBA address
    mov dword [si + 8], eax
    mov dword [si + 12], edx

    ; store the segment and address
    mov word [si + 4], di
    mov word [si + 6], es

    ; int 0x13 ah = 0x42 to read from the disk
    ; ds:si = pointer to DAP
    ; dl = drive number
    mov ah, 0x42
    mov dl, byte [boot_drive]
    int 0x13

    ; carry flag is set on error
    ; so we don't need to do this
    popa
    ret


sig_fail_msg: db 'stage two not found', 0
disk_err_msg: db 'disk fail', 0
error_msg:    db 'Fatal: ', 0

dap:
    .size  db 16
    .zero  db 0
    .count dw 1
.addr:
    .offs  dw KERNEL_ADDR
    .segm  dw 0

; might be changed by tools
.lba:
    .lba_low dd 4096
    .lba_high dd 0

boot_drive: db 0

times 440 - ($-$$) db 0

dd 0
dw 0

dq 0, 0
dq 0, 0
dq 0, 0
dq 0, 0

dw 0xAA55