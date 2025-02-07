section .data
    ; Define syscall numbers with meaningful names
    SYS_OPEN  equ 2    ; syscall number for open
    SYS_WRITE equ 1    ; syscall number for write
    SYS_CLOSE equ 3    ; syscall number for close
    SYS_EXIT  equ 60   ; syscall number for exit

    ; Messages
    msg db 'Hello Universe!', 0xa  ; Message to write to the file
    len equ $ - msg                ; Length of the message

    usage db 'Usage: ./asm14 <filename>', 0xa  ; Usage message
    usage_len equ $ - usage                      ; Length of the usage message

    ; File descriptor storage
    fd dq 0

section .bss
    ; Reserve 256 bytes for a buffer (not used in this code)
    buffer: resb 256

section .text
global _start          ; Must be declared for linker (ld)

_start:                ; Tell linker entry point

    ; Check if an argument is provided
    mov rcx, [rsp]     ; rsp contains the number of arguments (argc)
    cmp rcx, 2         ; Check if argc == 2 (program name + 1 argument)
    jl .error          ; If argc < 2, jump to .error

    ; Get the first argument (filename) from the stack
    mov rsi, [rsp + 16] ; rsp + 16 points to the first argument (argv[1])

    ; Open the file
    mov rdi, rsi        ; Filename
    mov rsi, 0102o      ; Flags: O_CREAT | O_WRONLY
    mov rdx, 0666o      ; Mode: 0666 (read/write permissions)
    mov rax, SYS_OPEN   ; Syscall number for open
    syscall

    ; Check if the file opening succeeded
    cmp rax, 0
    jl .exit            ; If rax < 0, exit the program

    ; Store the file descriptor
    mov [fd], rax

    ; Write "Hello, world!" to the file
    mov rdx, len        ; Message length
    mov rsi, msg        ; Message to write
    mov rdi, [fd]       ; File descriptor
    mov rax, SYS_WRITE  ; Syscall number for write
    syscall

    ; Close the file
    mov rdi, [fd]       ; File descriptor
    mov rax, SYS_CLOSE  ; Syscall number for close
    syscall

    ; Exit the program with success (code 0)
    mov rax, SYS_EXIT   ; Syscall number for exit
    xor rdi, rdi        ; Exit code 0
    syscall

.error:
    ; Print usage message to stderr (file descriptor 2)
    mov rdx, usage_len  ; Length of the usage message
    mov rsi, usage      ; Address of the usage message
    mov rdi, 2          ; File descriptor 2 (stderr)
    mov rax, SYS_WRITE  ; Syscall number for write
    syscall

    ; Exit the program with error code 1 (no argument provided)
    mov rax, SYS_EXIT   ; Syscall number for exit
    mov rdi, 1          ; Exit code 1
    syscall

.exit:
    ; Exit the program with error code (if file opening failed)
    mov rax, SYS_EXIT   ; Syscall number for exit
    xor rdi, rdi        ; Exit code 0 (default)
    syscall
