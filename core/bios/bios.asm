[extern prot_to_real]
[extern real_to_prot]

[bits 32]
[global bios_video_mode]
; void bios_video_mode(uint8_t mode);
bios_video_mode:
    push ebp
    mov ebp, esp

    mov dx, word [ebp + 8]

    call prot_to_real

    bits 16
    movzx ax, dl
    int 0x10

    call dword real_to_prot

    bits 32

    mov esp, ebp
    pop ebp
    ret
