section .text
    global asm07

asm07:
    ; Initialiser la somme à 0
    xor eax, eax
    mov ebx, [esp+4]
    dec ebx

sum_loop:
    test ebx, ebx
    jl done
    add eax, ebx
    dec ebx
    jmp sum_loop

done:
    ret
