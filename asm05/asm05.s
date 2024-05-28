section .bss
    result resb 10

section .text
    global asm05

asm05:
    ; Additionner les deux nombres
    mov eax, [esp+4]
    add eax, [esp+8]
    ; Convertir le résultat en chaîne
    call itoa

    ; Afficher le résultat
    mov eax, 4
    mov ebx, 1
    mov ecx, result
    mov edx, 10
    int 0x80

    ret

itoa:
    ; Convertir l'entier dans EAX en chaîne de caractères dans 'result'
    mov ecx, 10
    mov esi, result + 9
    mov byte [esi], 0
itoa_loop:
    xor edx, edx
    div ecx
    add dl, '0'
    dec esi
    mov [esi], dl
    test eax, eax
    jnz itoa_loop
    ret
