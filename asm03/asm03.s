section .data
    msg db "1337", 0

section .text
    global asm03

asm03:
    ; Vérifier le nombre d'arguments
    mov rdi, [rsp]
    cmp rdi, 2
    jne return_1

    ; Comparer l'argument avec 42
    mov rdi, [rsp+8]
    mov rsi, [rdi]
    cmp rsi, 42
    je display_and_return_0

return_1:
    mov eax, 1
    ret

display_and_return_0:
    mov eax, 1
    mov edi, 1
    lea rsi, [rel msg]
    mov edx, 4
    syscall

    mov eax, 0
    ret
