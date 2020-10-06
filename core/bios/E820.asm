bits 32

[extern prot_to_real]
[extern real_to_prot]
[extern mmap_start]
[extern mmap_end]


; uint32_t get_e820_map();

[global get_e820_map]
get_e820_map:
    push ebp
    push ebx
    push edi
    push esi


    mov edi, mmap_start
    mov ecx, mmap_end
    sub ecx, edi
    shr ecx, 2
    xor eax, eax

    rep stosd


    call prot_to_real
    bits 16

    ; set di to our map
    mov di, mmap_start

    ; ebx must be zero on start
    xor ebx, ebx

    ; initialize counter
    xor ebp, ebp

    ; load 'SMAP' value
    mov edx, 'PAMS'

    ; set E820 value
    mov eax, 0xE820

    ; force a valid ACPI 3.X entry
    mov dword [di + 20], 1

    ; ask for 24 bytes
    mov ecx, 24

    ; preforme int 0x15
    int 0x15

    ; carry flag on first call means not supported
    jc .failed

    ; edx may be trashed
    mov edx, 'PAMS'

    ; on sucess eax contains 'SMAP'
    cmp eax, edx
    jne .failed

    ; ebx = 0 means we have only 1 entry which is worthless
    cmp ebx, 0
    je .failed

    ; start the loop
    jmp .jump_in

    .loop_start:
        ; same as above
        mov eax, 0xE820
        mov ecx, 24
        mov dword [di + 20], 1
        int 0x15

        ; carry flag means end reached
        jc .done

        mov edx, 'PAMS'
    .jump_in:
        ; skip zero size entries
        jcxz .skip

        ; check for 24-byte entry
        cmp cl, 20
        jbe .not_ext

        ; check for the "ignore this data" bit
        test byte [di + 20], 1
        je .skip
    .not_ext:
        ; skip zero length areas
        mov ecx, dword [di + 8]
        or ecx, dword [di + 12]
        jz .skip

        ; we found a valid entry
        inc ebp
        add di, 24

        ; check if we have enough space
        cmp di, mmap_end
        je .done
    .skip:
        ; if ebx = 0 we are done
        test ebx, ebx
        jne .loop_start
        jmp .done

    .failed:
        mov ebp, 0
    .done:
        ; real_to_prot trashes ebp
        mov edx, ebp

    call dword real_to_prot
    bits 32

    pop esi
    pop edi
    pop ebx
    pop ebp

    ; set the return value
    mov eax, edx
    ret
