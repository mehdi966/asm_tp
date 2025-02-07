global _start

section .bss
    nb1 resb 32
    nb2 resb 32
    nb3 resb 32
    signNb1 resb 1 
    signNb2 resb 1
    signNb3 resb 1
    finalSign resb 1

section .data
    help: db "Return the biggest of 3 numbers passed as parameters", 10
    .lenHelp: equ $ - help
    usage: db "USAGE : ./asm10 NUMBER1 NUMBER2 NUMBER3", 10
    .lenUsage: equ $ - usage

section .text
_start:
    
    mov r13, [rsp]  ; is there the attended arguments ?
    cmp r13, 4
    jne _error

    mov rsi, rsp
    add rsi, 16
    mov rsi, [rsi]
    mov rdi, nb1    ; keeping first number
    mov rcx, 4
    rep movsb

    mov rsi, rsp
    add rsi, 24
    mov rsi, [rsi]
    mov rdi, nb2    ; keeping second number
    mov rcx, 4
    rep movsb

    mov rsi, rsp
    add rsi, 32
    mov rsi, [rsi]
    mov rdi, nb3    ; keeping second number
    mov rcx, 4
    rep movsb

    mov byte [signNb1], 0   ; we initalize the sign at positiv
    mov byte [signNb2], 0   ; it will change later if its negativ
    mov byte [signNb3], 0

    xor rdi, rdi
    mov r8, 0


sign1:                      ; change the value of sign1 var if the number1 is negativ
    mov al, [nb1 + rdi]
    cmp al, '-'             ; we check if the first char is a '-', meaning the number1 is negativ
    je ._negativ
    jne convert1            ; otherwise we can convert the first number
    ._negativ:    
        mov byte [signNb1], 1
        inc rdi
        jmp convert1
    
convert1: 
    mov al, [nb1 + rdi]
    cmp al, 0
    je done1

    cmp rax, '0'    ; we check if its a number or not, which means between char 0 (48) and char 9 (57)

    jl _error

    cmp rax, '9'
    jg _error

    sub rax, 48     ; we sub the value for char 0 (48) to get its decimal form
    imul r8, 10 ; imul to write number from left to right 
    add r8, rax

    inc rdi
    jmp convert1

done1:
    xor rdi, rdi
    mov r9, 0

sign2:              ; same as sign1 but for number2
    mov al, [nb2]
    cmp al, '-'
    je ._negativ
    jne convert2
    ._negativ:    
        inc rdi
        mov byte [signNb2], 1
        jmp convert2
 

convert2:
    mov al, [nb2 + rdi]
    cmp rax, 0
    je done2

    cmp rax, '0'
    jl _error

    cmp rax, '9'
    jg _error

    sub rax, 48
    imul r9, 10
    add r9, rax

    inc rdi
    jmp convert2

done2:
    xor rdi, rdi
    mov r10, 0

sign3:              ; same as sign1 but for number3
    mov al, [nb3]
    cmp al, '-'
    je ._negativ
    jne convert3
    ._negativ:    
        inc rdi
        mov byte [signNb3], 1
        jmp convert3
 

convert3:           ; same as convert1 but for number 3
    mov al, [nb3 + rdi]
    cmp rax, 0
    je done3

    cmp rax, '0'
    jl _error

    cmp rax, '9'
    jg _error

    sub rax, 48
    imul r10, 10
    add r10, rax

    inc rdi
    jmp convert3

done3:
    mov r11, 0 ; will count the negativ numbers, i.e 1, 2 or 3
    
    ._nb1: ; we check each number
        mov al, [signNb1]
        cmp al, 1
        je ._nb1IsNeg
        jne ._nb2

        ._nb1IsNeg: ; if number sign [signNb*] is 1 it means its negativ
            inc r11

    ._nb2: ; same as nb1 for nb2
        mov al, [signNb2]
        cmp al, 1
        je ._nb2IsNeg
        jne ._nb3

        ._nb2IsNeg:
            inc r11

    ._nb3: ; same as nb1 for nb3
        mov al, [signNb2]
        cmp al, 1
        je ._nb3IsNeg
        jmp ._diffPosNeg

        ._nb3IsNeg:
            inc r11

    ._diffPosNeg:  
        cmp r11, 3 ; we check if we have only negativs number, if so we jump straight to the negativ comparaison
        je ._negativs
        cmp r11, 0
        je ._positivs
        
        ._check1:       ; we get to this case if we got 1 or 2 negativs.
                        ; if we do we check each number  sign once again to set the number to 0. They will act as positiv
                        ; but since no positiv can be lower than 0, its not a problem and will be fine don't worry
            mov al, [signNb1]
            cmp al, 1
            je ._nb1Neg
            jne ._check2

            ._nb1Neg:
                mov r8, 0
            
        ._check2:
            mov bl, [signNb2]
            cmp bl, 1
            je ._nb2Neg
            jne ._check3

            ._nb2Neg:
                mov r9, 0

        ._check3:
            mov cl, [signNb3]
            cmp cl, 1
            je ._nb3Neg
            jne ._positivs

            ._nb3Neg:
                mov r10, 0


    ._positivs: ; if numbers are not all negativs, we use this case, we compare every number together. 
                ; negativs number have been set to 0 before
                ; so we don't bother checking them right here since no positiv number can be lower than 0
        cmp r8, r9
        ja ._nb1GreaterPos
        jb ._nb2GreaterPos
    
        ._nb1GreaterPos:
            cmp r8, r10
            jb ._nb3GreaterPos
            mov rax, r8
            mov rcx, 0
            call std__to_string
            jmp _exit
        ._nb2GreaterPos:
            cmp r9, r10
            jb ._nb3GreaterPos
            mov rax, r9
            mov rcx, 0
            call std__to_string
            jmp _exit
        ._nb3GreaterPos:
            mov rax, r10
            mov rcx, 0
            call std__to_string
            jmp _exit
    
    ._negativs:  ; if all numbers are negativ, we need to reverse the comparaison ja becomes jb etc
        cmp r8, r9
        jb ._nb1GreaterNeg
        ja ._nb2GreaterNeg
    
        ._nb1GreaterNeg:
            cmp r8, r10
            ja ._nb3GreaterNeg
            mov rax, r8
            mov rcx, 1
            call std__to_string
            jmp _exit
        ._nb2GreaterNeg:
            cmp r9, r10
            ja ._nb3GreaterNeg
            mov rax, r9
            mov rcx, 1
            call std__to_string
            jmp _exit
        ._nb3GreaterNeg:
            mov rax, r10
            mov rcx, 1
            call std__to_string
            jmp _exit

_exit:
    mov rax, 1
    mov rdi, 1
    syscall

    mov rax, 60
    mov rdi, 0
    syscall


_error:

    mov rax, 1    ; print help message if there is an error
    mov rdi, 1
    mov rsi, help
    mov rdx, help.lenHelp
    syscall
    
    mov rax, 1
    mov rdi, 1
    mov rsi, usage
    mov rdx, usage.lenUsage
    syscall

    mov rax, 60
    mov rdi, 1 
    syscall


std__to_string:
    ; ----------------------------------------------------------------------
    ;    TAKES
    ;        ||------> 1. RAX => Number
    ;                  2. RSI => Output string
    ;                  3. RCX => finalSign (0 or 1)
    ;
    ;    GIVES
    ;        ||------> 1. RSI = Number as a string
    ;                  2. RDX = Length of the string (number of digits)
    ;
    ; ----------------------------------------------------------------------

    push rsi              ; Keep the output string pointer on the stack for later
    push rax              ; Keep the value of RAX on the stack because the next loop will change its value

    cmp rcx, 1            ; Check if finalSign is 1
    jne .no_sign          ; If not, jump to .no_sign

    mov byte [rsi], '-'   ; Add '-' at the beginning of the string
    inc rsi               ; Increment the string pointer
    mov rdi, 2            ; Set the initial number of digits to 2 to account for the negative sign

    jmp .continue         ; Jump to the main loop

.no_sign:
    mov rdi, 1            ; Set the initial number of digits to 1 (no negative sign)

.continue:
    mov rcx, 1            ; For keeping the divisor
    mov rbx, 10           ; For dividing the number by ten in each iteration 
    .get_divisor:
        xor rdx, rdx
        div rbx           ; Reduce the RAX by one digit
        
        cmp rax, 0        ; Compare RAX with zero
        je ._after         ; Break the loop if equal
        imul rcx, 10      ; Otherwise increase the divisor (RCX) ten times
        inc rdi           ; Increment number of digits as well (RDI)
        jmp .get_divisor   ; Unconditional jump to the first instruction of the 'loop'

    ._after:
        pop rax           ; Get back the value of RAX from the stack
        push rdi          ; Put the number of digits on the stack for later

    .to_string:
        xor rdx, rdx
        div rcx           ; Divide the number (RAX) by the divisor to get the first digit from the left

        add al, '0'       ; Add the base (48) to the digit because we want to store an ASCII string
        mov [rsi], al     ; Move the value into the string
        inc rsi           ; Increment the pointer to the next byte

        push rdx          ; Push the remaining part of the number onto the stack
        xor rdx, rdx      
        mov rax, rcx     
        mov rbx, 10       
        div rbx           ; Reduce the divisor (RCX) ten times
        mov rcx, rax      ; Put the new divisor back into (RCX)

        pop rax           ; Pop the top the stack into (RAX). It's the remaining part of the number
        
        cmp rcx, 0        ; See if the divisor has become zero
        jg .to_string      ; If not, repeat the same process
    
    mov byte [rsi + rdx], 0
    pop rdx               ; Pop the top of the stack into (RDX). It's the value of (RDI): the number of digits in the original number
    pop rsi               ; Bring (RSI) to the beginning of the string before returning as well
    ret
