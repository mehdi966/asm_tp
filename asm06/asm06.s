section .text
    global asm06

asm06:
    ; Code pour vérifier si le nombre est premier
    mov eax, [esp+4]
    cmp eax, 2
    jl not_prime
    mov ecx, 2
prime_check_loop:
    mov edx, 0
    div ecx
    test edx, edx
    jz not_prime
    inc ecx
    cmp ecx, eax
    jl prime_check_loop
    mov eax, 0
    ret

not_prime:
    mov eax, 1
    ret
