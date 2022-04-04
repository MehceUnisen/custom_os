[org 0x7c00] ; bootloader offset

KERNEL_OFFSET equ 0x7e00

mov [BOOT_DRIVE], dl
mov bp, 0x9000 ;initailize the stack
mov sp, bp

call load_kernel
call enable_a20
call switch_to_pm
jmp $ ; this will actually never be executed

%include "print.asm"
%include "gdt.asm"
%include "32bit_print.asm"
%include "32bit_switch.asm"
%include "disk_read.asm"

[bits 16]
load_kernel:
    mov bx, KERNEL_OFFSET
    mov dh, 4
    mov dl, [BOOT_DRIVE]
    call load_disk
    ret


[bits 32]

%include "64bit_switch.asm"
%include "identity_paging.asm"

BEGIN_PM: ; after the switch we will get here
    ;entering PM succesfully!
    
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    call check_cpu_id
    call detect_long_mode
    call set_paging
    call edit_gdt
    

    call CODE_SEG:begin_lm

    jmp $


[bits 64]
begin_lm:
    mov edi, 0xB8000              ; Set the destination index to 0xB8000.
    mov rax, 0x1F201F201F201F20   ; Set the A-register to 0x1F201F201F201F20.
    mov ecx, 500                  ; Set the C-register to 500.
    rep stosq                     ; Clear the screen.
    call KERNEL_OFFSET ; have a better understanding offsetting!
    ; mov [0xb9200], byte 'P'
    ; mov [0xb9202], byte 'P'
    ; mov [0xb9204], byte 'P'
    hlt                           ; Halt the processor.


[bits 32]

BOOT_DRIVE db 0
; bootsector
times 510-($-$$) db 0
dw 0xaa55
