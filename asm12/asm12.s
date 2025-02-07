section .data
    buffer db 256 dup(0)  ; Buffer pour stocker l'entrée utilisateur

section .bss
    len resb 1            ; Pour stocker la longueur de la chaîne

section .text
    global _start

_start:
    ; Lire l'entrée standard (stdin)
    mov rax, 0            ; syscall: read
    mov rdi, 0            ; file descriptor: stdin
    mov rsi, buffer       ; buffer pour stocker l'entrée
    mov rdx, 256          ; nombre maximum d'octets à lire
    syscall

    ; Trouver la longueur de la chaîne
    mov rcx, rax          ; RAX contient le nombre d'octets lus
    dec rcx               ; Ignorer le caractère de nouvelle ligne
    mov [len], rcx        ; Stocker la longueur de la chaîne

    ; Inverser la chaîne
    lea rsi, [buffer]     ; RSI pointe vers le début de la chaîne
    lea rdi, [buffer + rcx - 1] ; RDI pointe vers la fin de la chaîne

reverse_loop:
    cmp rsi, rdi          ; Comparer les pointeurs
    jge print_reversed    ; Si RSI >= RDI, la chaîne est inversée

    ; Échanger les caractères
    mov al, [rsi]         ; Charger le caractère de gauche
    mov bl, [rdi]         ; Charger le caractère de droite
    mov [rsi], bl         ; Échanger les caractères
    mov [rdi], al

    ; Déplacer les pointeurs
    inc rsi               ; Déplacer RSI vers la droite
    dec rdi               ; Déplacer RDI vers la gauche
    jmp reverse_loop      ; Répéter

print_reversed:
    ; Afficher la chaîne inversée
    mov rax, 1            ; syscall: write
    mov rdi, 1            ; file descriptor: stdout
    mov rsi, buffer       ; buffer contenant la chaîne inversée
    mov rdx, [len]        ; longueur de la chaîne
    syscall

    ; Retourner 0
    mov rax, 60           ; syscall: exit
    xor rdi, rdi          ; code de retour: 0
    syscall
