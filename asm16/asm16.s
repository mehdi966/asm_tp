%define SYS_EXIT  60  ; Exit syscall
%define SYS_OPEN  2   ; Open file syscall
%define SYS_READ  0   ; Read file syscall
%define SYS_WRITE 1   ; Write to file syscall
%define SYS_LSEEK 8   ; Lseek syscall
%define SYS_CLOSE 3   ; Close file syscall

%define O_RDWR    2   ; Read-write mode
%define SEEK_SET  0   ; Seek from beginning of file

section .data
    ; Messages
    usage_msg       db "usage: ./asm16 <binary>", 0x0A
    usage_msg_len   equ $ - usage_msg

    error_msg       db "Error: Unable to patch the file.", 0x0A
    error_msg_len   equ $ - error_msg

    success_msg     db "Patch successful.", 0x0A
    success_msg_len equ $ - success_msg

    ; New string to write
    new_bytes       db "H4CK", 0x00
    patch_len       equ $ - new_bytes

section .bss
    ; Buffer to store the first 5 bytes of the file (ELF header)
    elf_header      resb 5

section .text
    global _start

_start:
    ; Check if exactly one argument is provided
    mov rcx, [rsp]
    cmp rcx, 2
    jne .show_usage

    ; Get the filename from argv[1]
    mov rsi, [rsp + 16]

    ; Open the file in read-write mode
    mov rax, SYS_OPEN
    mov rdi, rsi
    mov rsi, O_RDWR
    mov rdx, 0
    syscall
    cmp rax, 0
    jl .exit_with_error
    mov r8, rax          ; Save file descriptor

    ; Seek to offset 0x1000
    mov rax, SYS_LSEEK
    mov rdi, r8
    mov rsi, 0x1000
    mov rdx, SEEK_SET
    syscall
    cmp rax, 0x1000
    jne .exit_with_error

    ; Write "H4CK" followed by null terminator
    mov rax, SYS_WRITE
    mov rdi, r8
    lea rsi, [new_bytes]
    mov rdx, patch_len
    syscall
    cmp rax, patch_len
    jne .exit_with_error

    ; Close the file
    mov rax, SYS_CLOSE
    mov rdi, r8
    syscall

    ; Print success message
    mov rax, SYS_WRITE
    mov rdi, 1
    lea rsi, [success_msg]
    mov rdx, success_msg_len
    syscall

    ; Exit successfully
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

.exit_with_error:
    ; Print error message
    mov rax, SYS_WRITE
    mov rdi, 2
    lea rsi, [error_msg]
    mov rdx, error_msg_len
    syscall

    ; Exit with error code
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall

.show_usage:
    ; Print usage message
    mov rax, SYS_WRITE
    mov rdi, 2
    lea rsi, [usage_msg]
    mov rdx, usage_msg_len
    syscall

    ; Exit with error code
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall
