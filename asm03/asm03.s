section .data
    msg db "1337", 0

section .bss
    num resb 8

section .text
    global asm03

asm03:
    ; Vérifier le nombre d'arguments
    mov rax, [rsp]   ; Nombre d'arguments
    cmp rax, 2
    jne return_1

    ; Comparer l'argument avec 42
    mov rdi, [rsp+8] ; Adresse de la chaîne de l'argument
    call string_to_int
    cmp rax, 42
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

string_to_int:
    ; Convertir la chaîne en entier
    xor rax, rax    ; Clear RAX (result)
    xor rcx, rcx    ; Clear RCX (multiplier)
    xor rdx, rdx    ; Clear RDX (digit)
convert_loop:
    mov dl, byte [rdi + rcx]
    test dl, dl
    je end_convert
    sub dl, '0'
    imul rax, rax, 10
    add rax, rdx
    inc rcx
    jmp convert_loop
end_convert:
    ret
