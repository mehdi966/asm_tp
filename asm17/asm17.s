section .data
    SYS_read     equ 0
    SYS_write    equ 1
    SYS_exit     equ 60
    STDIN        equ 0
    STDOUT       equ 1
    BUF_SIZE     equ 256

    ; Usage message
    usage_msg    db "Usage: echo 'message' | ./asm17 <shift>", 10
    usage_len    equ $ - usage_msg

section .bss
    buf:         resb BUF_SIZE

section .text
    global _start

_start:
    ; Retrieve the shift value from argv[1]
    pop rdi          ; Discard argc
    pop rsi          ; Pop argv[0] (program name)
    pop rdx          ; Pop argv[1] (shift value)

    ; Check if argv[1] is provided
    cmp rdx, 0
    je show_usage    ; If no shift value, show usage and exit

    ; Convert shift value from ASCII to integer
    mov al, byte [rdx]
    sub al, '0'      ; Convert ASCII digit to integer
    mov byte [shift], al
    jmp continue

show_usage:
    ; Display usage message
    mov eax, SYS_write
    mov edi, STDOUT
    mov esi, usage_msg
    mov edx, usage_len
    syscall

    ; Exit with error code 1
    mov eax, SYS_exit
    mov edi, 1
    syscall

continue:
    ; Read input from stdin
    mov eax, SYS_read
    mov edi, STDIN
    mov esi, buf
    mov edx, BUF_SIZE - 1
    syscall

    ; Null-terminate the input
    mov byte [buf + rax], 0

    ; Process each character in the buffer
    xor rcx, rcx      ; rcx is the index
process_char:
    mov al, byte [buf + rcx]
    cmp al, 0
    je done_processing

    ; Check if it's a lowercase letter
    cmp al, 'a'
    jl not_lower
    cmp al, 'z'
    jg not_lower

    ; Shift lowercase letter
    sub al, 'a'        ; Convert to 0-25
    add al, byte [shift]
    mov bl, 26
    xor ah, ah
    div bl             ; AX / BL, AH has remainder
    add ah, 'a'        ; Shifted letter
    mov al, ah
    mov byte [buf + rcx], al
    jmp next_char

not_lower:
    ; Check if it's an uppercase letter
    cmp al, 'A'
    jl next_char
    cmp al, 'Z'
    jg next_char

    ; Shift uppercase letter
    sub al, 'A'        ; Convert to 0-25
    add al, byte [shift]
    mov bl, 26
    xor ah, ah
    div bl             ; AX / BL, AH has remainder
    add ah, 'A'        ; Shifted letter
    mov al, ah
    mov byte [buf + rcx], al

next_char:
    inc rcx
    jmp process_char

done_processing:
    ; Write the result to stdout
    mov eax, SYS_write
    mov edi, STDOUT
    mov esi, buf
    mov rdx, rcx       ; Use rdx instead of edx
    syscall

    ; Exit the program
    mov eax, SYS_exit
    xor edi, edi
    syscall

section .data
    shift:   db 0
