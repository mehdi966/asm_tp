section .data
    msg db "1337", 0

section .text
    global asm03

asm03:
    ; Comparer l'entrée avec 42
    cmp dword [esp+4], 42
    je display_and_return_0

    ; Sinon, retourner 1
    mov eax, 1
    ret

display_and_return_0:
    ; Afficher 1337
    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, 4
    int 0x80

    ; Retourner 0
    mov eax, 0
    ret
