section .text
    global asm04

asm04:
    ; Vérifier si le nombre est pair
    mov eax, [esp+4]
    test eax, 1
    jz return_0

    ; Sinon, retourner 1
    mov eax, 1
    ret

return_0:
    mov eax, 0
    ret
