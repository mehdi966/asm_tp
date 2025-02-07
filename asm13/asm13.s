section .data
    buffer_size  equ 256
    stdin        equ 0
    stdout       equ 1
    stderr       equ 2
    sys_read     equ 0
    sys_write    equ 1
    sys_exit     equ 60

section .bss
    buffer: resb buffer_size

section .data
    error_msg: db "Error reading input.", 10
    error_msg_len: equ $ - error_msg

section .text
    global _start

_start:
    ; Read input from stdin
    mov rax, sys_read          ; syscall number for read
    mov rdi, stdin             ; file descriptor 0 (stdin)
    mov rsi, buffer            ; address of buffer to store input
    mov rdx, buffer_size - 1   ; number of bytes to read (leave space for null terminator)
    syscall

    ; Check if read was successful
    cmp rax, -1
    je error

    ; Null-terminate the buffer
    mov rcx, rax               ; number of bytes read
    mov rdi, buffer            ; pointer to buffer
    add rdi, rcx               ; position to null-terminate
    mov byte [rdi], 0          ; null terminator

    ; Strip newline character if present
    mov rsi, buffer            ; pointer to start of buffer
    mov rdx, rax               ; current length of string
    cmp byte [rsi + rdx - 1], 10
    je strip_newline
    jmp check_palindrome

strip_newline:
    dec rdx                    ; decrement length
    mov byte [rsi + rdx], 0    ; null terminate before newline

check_palindrome:
    mov r8, rsi                ; r8 = start pointer
    mov r9, rsi                ; r9 = end pointer
    add r9, rdx                ; move end pointer to the end of the string
    dec r9                     ; adjust end pointer to last character

palindrome_loop:
    ; Check if start pointer is greater than or equal to end pointer
    cmp r8, r9
    jge is_palindrome

    ; Compare the characters at r8 and r9
    mov al, byte [r8]
    mov bl, byte [r9]
    cmp al, bl
    jne not_palindrome

    ; Move pointers towards the center
    inc r8
    dec r9
    jmp palindrome_loop

is_palindrome:
    ; Exit with status code 0
    mov rax, sys_exit
    xor rdi, rdi
    syscall

not_palindrome:
    ; Exit with status code 1
    mov rax, sys_exit
    mov rdi, 1
    syscall

error:
    ; Handle error (e.g., print error message)
    mov rax, sys_write
    mov rdi, stderr
    mov rsi, error_msg
    mov rdx, error_msg_len
    syscall

    ; Exit with status code 2
    mov rax, sys_exit
    mov rdi, 2
    syscall
