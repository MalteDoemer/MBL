bits 16
section .boot

global start

extern bss_start
extern bss_end
extern entry
extern sect_cnt

%define LBA_MODE 1
%define CHS_MODE 0

start:
    jmp short skipfat
    nop
    times 90 -($-$$) db 0

    ; the LBA of second stage
    ; will be changed by installer
lba_low dd 0
lba_high dd 0

skipfat:
    ; disable interrupts and clear direction flag
    cli
    cld

    ; clear all segment registers
    xor cx, cx
    mov ds, cx
    mov ss, cx
    mov es, cx

    ; copy from 0x7C00 -> 0x600
    mov di, start
    mov si, 0x7C00

    ; set up the stack at 0x600
    mov sp, di

    ; copy 512 bytes
    mov ch, 1
    rep movsw

    ; clear code segment
    jmp 0:next

next:
    ; clear out bss section
    mov di, bss_start
    mov cx, bss_end
    sub cx, di
    mov al, 0
    rep stosb

    ; enable interrupts
    sti

    ; save boot drive
    mov byte [drive], dl

    ; used by lba_mode and chs_mode
    mov si, disk_info

    ; check for LBA extensions
    mov ah, 0x41
    mov bx, 0x55AA
    int 0x13

    jc chs_mode
    cmp bx, 0xAA55
    jne chs_mode
    and cx, 1
    jz chs_mode

lba_mode:
    ; set the mode for later use
    mov byte [si - 1], LBA_MODE

    ; set size and zero byte
    mov word [si], 0x1000

    ; set sector count
    mov word [si + 2], sect_cnt

    ; copy low 32-bits of LBA
    mov eax, dword [lba_low]
    mov dword [si + 8], eax

    ; copy high 32-bits of LBA
    mov eax, dword [lba_high]
    mov dword [si + 12], eax

    ; load at 0x80:0x00
    mov eax, 0x800000
    mov dword [si + 4], eax

    ; get the boot drive
    mov dl, byte [drive]

    ; BIOS call "INT 0x13 Function 0x42" to read sectors from disk into memory
    ;   Call with 
    ;       ah = 0x42
    ;	    dl = drive number
    ;		ds:si = segment:offset of disk address packet
    ;   Return:
    ;	    ah = 0x0 on success; err code on failure

    mov ah, 0x42
    int 0x13

    ; carry flag should be set on error
    jc read_error

    ; check the number of sectors written
    cmp word [si + 2], sect_cnt
    jne read_error

    ; go on to the next stage
    jmp entry

chs_mode:
    ; set the mode for later use
    mov byte [si - 1], CHS_MODE

    ; int 0x13 with ah = 0x08 to determine drive geometry
    mov ah, 0x08
    mov dl, byte [drive]
    int 0x13

    jc geom_error

    ; save number of heads
    inc dh
    mov byte [si + 2], dh

    ; save number of sectors
    mov al, cl
    and al, 0x3F
    mov byte [si + 3], al

    ; store number of cylinder
    movzx ax, cl
    shl ax, 2
    mov al, ch
    mov word [si], ax

    ; upper 32-bits must be zero
    mov edx, dword [lba_high]
    or edx, edx
    jnz chs_error

    ; get the LBA
    mov eax, dword [lba_low]

    ; get number of sectors
    movzx ebx, byte [si + 3]

    ; divide by number of sectors
    div ebx

    ; save sector start
    mov cl, dl
    inc cl

    ; get number of heads
    movzx ebx, byte [si + 2]

    ; divide by number of headss
    xor dx, dx
    div ebx

    ; check if we need to many cylinders
    cmp ax, word [si]
    jae chs_error

    ; low bits of cylinder start
    mov ch, al

    ; high 2-bits of cylinder start
    mov al, 0
    shr ax, 2
    or cl, al

    ; set head start
    mov dh, dl

    ; get the drive back
    mov dl, byte [drive]

    ; set number of sectors to read
    mov al, sect_cnt

    ; load at 0x80:0x00
    mov bx, 0x80
    mov es, bx
    xor bx, bx

    ; BIOS call "INT 0x13 Function 0x2" to read sectors from disk into memory
    ;   Call with
    ;       ah = 0x2
    ;       al = number of sectors
    ;       ch = cylinder
    ;       cl = sector (bits 6-7 are high bits of "cylinder")
    ;       dh = head
    ;       dl = drive (0x80 for hard disk, 0x0 for floppy disk)
    ;       es:bx = segment:offset of buffer
    ;   Return:
    ;       ah = 0x0 on success; err code on failure

    mov ah, 0x02
    int 0x13
    
    ; carry flag should be set on error
    jc read_error

    ; check the number of sectors written
    cmp al, sect_cnt
    jne read_error

    jmp entry

geom_error:
    push word geom_error_msg
    jmp error

chs_error:
    mov si, chs_error_msg
    push si
    ; push word chs_error_msg
    jmp error

read_error: 
    push word read_error_msg

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
    int 0x10
    jmp print
.done:
    ret


error_msg: db 'Fatal error: ', 0
read_error_msg: db 'disk read fail', 0
geom_error_msg: db 'no disk info', 0
chs_error_msg: db 'chs too large', 0

section .bss
disk_mode resb 1
disk_info resb 16
drive resb 1