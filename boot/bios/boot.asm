org 0x600


%ifdef FAT
%ifdef MBR
%error "MBR and FAT both defined"
%endif
%elifndef MBR
%error "Must define FAT or MBR"
%endif

%define KERNEL_ADDR 0x800

%ifdef FAT
%define DEFAULT_LBA 1
%elifdef MBR
%define DEFAULT_LBA 4096
%endif

start:

%ifdef FAT
    ; on a FAT partition we need to skip the BPB
    jmp short skip_bpb
    times 90 - ($-$$) nop
skip_bpb:
%endif

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

    ; set si to point to the dap
    mov si, dap

    ; if carry flag is set LBA isn't supported
    jc chs_mode

    ; bx must be 0xAA55
    cmp bx, 0xAA55
    jne chs_mode

    ; cx bit #1 must be set
    and cx, 1
    jz chs_mode

    ; store the right read function 
    mov word [read_func], lba_read

    ; load the second stage!
    jmp load

chs_mode:
    ; int 0x13 with ah = 0x08 to 
    ; get info about the drive
    mov ah, 0x08
    mov dl, byte [boot_drive]
    int 0x13

    ; TODO add fallback method
    jc no_geom

    ; store the maximum number of sectors
    mov al, cl
    and al, 00111111b
    mov byte [si + 2], al

    ; store the maximum number of heads
    mov byte [si + 3], dh

    ; store the maximum cylinder number
    movzx dx, cl
    shl dx, 2
    mov ah, dh
    mov al, ch
    mov word [si], ax

    ; store the function to use
    mov word [read_func], chs_read

load:
    ; let es:di point to the load address
    mov ax, KERNEL_ADDR / 16
    mov es, ax
    xor di, di

    ; get the LBA to load at
    mov eax, dword [si + 8]
    mov edx, dword [si + 12]

    ; save the LBA for second stage
    push eax
    push edx

read_loop:
    ; read one sector from disk
    call word [read_func]

    ; carry flag is set on error
    jc read_fail
    
    ; increment the LBA
    add eax, 1
    adc edx, 0

    add di, 512

    ; we want to read until di overflows
    ; in order to load 64 KiB
    jnc read_loop

    ; pass the boot drive on the stack
    movzx dx, byte [boot_drive]
    push dx

    ; jump into the second stage
    jmp KERNEL_ADDR

no_geom:
    push word no_geom_msg
    jmp error
chs_err:
    push word chs_err_msg
    jmp error
read_fail:
    push word read_fail_msg
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


; IN: edx:eax LBA;  es:di = buffer; si = dap
; OUT: carry flag set on error
chs_read:
    pusha

    ; int 0x13 ah = 0x02 to read from disk
    ; al = number of sector to read (1)
    ; ch = low 8-bits of cylinder number
    ; cl = bits 0:5 sector number, bits 6:7 high tow bits of cylinder
    ; dh = head number
    ; dl = drive number
    ; es:bx = transfer buffer


    ; chs can't handle large LBA's
    or edx, edx
    jnz chs_err

    ; get sectors per track
    xor ebx, ebx
    mov bl, byte [si + 2]

    ; divide LBA with sectors per track
    div ebx

    ; get the sector number into cl
    mov cl, dl

    ; sector number is 1-based
    inc cl

    ; clear edx
    xor dx, dx

    ; get the number of heads
    xor ebx, ebx
    mov bl, byte [si + 3]

    ; divide with number of heads
    div ebx

    ; get the head number into dh
    mov dh, dl

    ; check if the cylinders are in range
    cmp ax, word [si]
    jae chs_err

    ; low 8-bits of cylinder
    mov ch, al

    ; high 2-bits of cylinder
    mov al, 0
    shr ax, 2
    or cl, al

    ; buffer must be in es:bx
    mov bx, di

    ; get the drive number
    mov dl, byte [boot_drive]

    ; ah = 2, al = 1
    mov ax, 0x201
    clc
    int 0x13

    popa
ret

; IN: edx:eax LBA;  es:di = buffer; si = dap
; OUT: carry flag set on error
lba_read:
    ; presreve all registers
    pusha

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


read_fail_msg: db 'read failure', 0
chs_err_msg: db 'invalid CHS address', 0
no_geom_msg: db 'no geometry info', 0
error_msg:    db 'Fatal: ', 0

; DAP stores information where to load the second stage
dap:
    .size  db 16
    .zero  db 0
    .count dw 1
.addr:
    .offs  dw 0
    .segm  dw 0

; might be changed by tools
.lba:
    .lba_low dd DEFAULT_LBA
    .lba_high dd 0


boot_drive: db 0
read_func: dw 0


%ifdef MBR

; on a MBR wee need to resreve 
; space for the partition table
times 440 - ($-$$) db 0

dd 0
dw 0

dq 0, 0
dq 0, 0
dq 0, 0
dq 0, 0

%else

times 510 - ($-$$) db 0

%endif

dw 0xAA55