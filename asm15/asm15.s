section .data
    ; Syscall numbers
    sys_exit        equ 60   ; Exit syscall
    sys_open        equ 2    ; Open file syscall
    sys_read        equ 0    ; Read file syscall
    sys_close       equ 3    ; Close file syscall
    sys_write       equ 1    ; Write syscall

    ; File open flags
    O_RDONLY        equ 0    ; Read-only mode

    ; ELF magic number (first 4 bytes of an ELF file)
    elf_magic       db 0x7F, 'E', 'L', 'F'  ; ELF magic number
    elf_class64     db 2                    ; ELF class (1 = 32-bit, 2 = 64-bit)

    ; Error messages
    usage_msg       db "usage: ./asm15 <binary>", 0x0A  ; Usage message with newline
    usage_msg_len   equ $ - usage_msg                   ; Length of the usage message

section .bss
    ; Buffer to store the first 5 bytes of the file (ELF header)
    elf_header      resb 5

section .text
    global _start

_start:
    ; Check if a filename is provided as an argument
    cmp qword [rsp], 2       ; argc should be 2 (program name + filename)
    jne .show_usage          ; If not, show usage message and exit

    ; Open the file passed as an argument
    mov rax, sys_open        ; sys_open syscall
    mov rdi, qword [rsp + 16]      ; argv[1] (filename pointer)
    mov rsi, O_RDONLY        ; O_RDONLY (read-only mode)
    mov rdx, 0               ; No mode needed for reading
    syscall

    ; Check if the file was opened successfully
    cmp rax, 0               ; File descriptor should be >= 0
    jl .invalid_input        ; If negative, exit with error

    ; Save the file descriptor
    mov r8, rax              ; Store file descriptor in r8

    ; Read the first 5 bytes of the file (ELF header)
    mov rax, sys_read        ; sys_read syscall
    mov rdi, r8              ; File descriptor
    lea rsi, [elf_header]    ; Buffer to store the header
    mov rdx, 5               ; Read 5 bytes
    syscall

    ; Check if the read was successful
    cmp rax, 5               ; We should have read exactly 5 bytes
    jne .invalid_input       ; If not, exit with error

    ; Close the file
    mov rax, sys_close       ; sys_close syscall
    mov rdi, r8              ; File descriptor
    syscall

    ; Check if the file is a valid ELF file
    movzx eax, byte [elf_header]   ; First byte
    cmp al, 0x7F
    jne .not_elf

    movzx eax, byte [elf_header + 1]
    cmp al, 'E'
    jne .not_elf

    movzx eax, byte [elf_header + 2]
    cmp al, 'L'
    jne .not_elf

    movzx eax, byte [elf_header + 3]
    cmp al, 'F'
    jne .not_elf

    ; Check if the ELF file is 64-bit
    movzx eax, byte [elf_header + 4]
    cmp al, 2
    jne .not_elf

    ; If we reach here, the file is a valid 64-bit ELF file
    mov rdi, 0               ; Return 0 (success)
    jmp .exit

.not_elf:
    ; The file is not a valid 64-bit ELF file
    mov rdi, 1               ; Return 1 (error)
    jmp .exit

.invalid_input:
    ; Invalid input or file error
    mov rdi, 1               ; Return 1 (error)
    jmp .exit

.show_usage:
    ; Display the usage message
    mov rax, sys_write       ; sys_write syscall
    mov rdi, 1               ; File descriptor 1 (stdout)
    lea rsi, [usage_msg]     ; Pointer to the usage message
    mov rdx, usage_msg_len   ; Length of the usage message
    syscall

    ; Exit with error code 1
    mov rdi, 1               ; Return 1 (error)

.exit:
    ; Exit the program
    mov rax, sys_exit        ; sys_exit syscall
    syscall
