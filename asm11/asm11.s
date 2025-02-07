global _start

section .bss
    input resb 256  ; Buffer to store the input
    output resb 12  ; Buffer to store the result (max 10 digits + newline + null)

section .data
    help: db "Return the number of vowels in the word passed as input", 10
    .lenHelp: equ $ - help

section .text
_start:
    ; Read input from stdin
    mov rax, 0            ; syscall: read
    mov rdi, 0            ; file descriptor: stdin
    mov rsi, input        ; buffer to store the input
    mov rdx, 256          ; maximum number of bytes to read
    syscall

    ; Check if read was successful
    cmp rax, 0            ; if no bytes were read, exit
    jle _exit

    ; Initialize vowel counter and index
    xor rdi, rdi          ; rdi = index in input
    xor r8, r8            ; r8 = vowel counter (initialized to 0)

._code:
    mov al, [input + rdi] ; al = current character
    inc rdi               ; Increment the index
    cmp al, 10            ; Check for newline (end of input)
    je ._end

    ; Check if the character is a vowel (lowercase or uppercase)
    cmp al, 'a'
    je ._found
    cmp al, 'e'
    je ._found
    cmp al, 'i'
    je ._found
    cmp al, 'o'
    je ._found
    cmp al, 'u'
    je ._found
    cmp al, 'y'
    je ._found
    cmp al, 'A'
    je ._found
    cmp al, 'E'
    je ._found
    cmp al, 'I'
    je ._found
    cmp al, 'O'
    je ._found
    cmp al, 'U'
    je ._found
    cmp al, 'Y'
    je ._found
    jmp ._code

._found:
    inc r8                ; Increment the vowel counter
    jmp ._code

._end:
    ; Convert the vowel counter (r8) to a string
    mov rax, r8           ; RAX = number to convert
    mov rsi, output       ; RSI = output buffer
    call std__to_string   ; Call the conversion function

    ; Add a newline at the end of the string
    mov byte [rsi + rdx], 10
    inc rdx               ; Increment the length to include the newline

    ; Print the result
    mov rax, 1            ; syscall: write
    mov rdi, 1            ; file descriptor: stdout
    mov rsi, output       ; buffer to print
    syscall

_exit:
    mov rax, 60           ; syscall: exit
    xor rdi, rdi          ; return code: 0
    syscall

; ----------------------------------------------------------------------
;    TAKES
;        ||------> 1. RAX => Number
;                  2. RSI => Output string
;
;    GIVES
;        ||------> 1. RSI = Number as a string
;                  2. RDX = Length of the string (number of digits)
;
; ----------------------------------------------------------------------
std__to_string:
    push rsi              ; Save the output string pointer on the stack
    push rax              ; Save the value of RAX on the stack

    mov rdi, 1            ; Set the initial number of digits to 1 (no negative sign)
    mov rcx, 1            ; To store the divisor
    mov rbx, 10           ; To divide the number by ten in each iteration

.get_divisor:
    xor rdx, rdx
    div rbx               ; Reduce RAX by one digit

    cmp rax, 0            ; Compare RAX with zero
    je ._after            ; Break the loop if equal
    imul rcx, 10          ; Otherwise, multiply the divisor (RCX) by ten
    inc rdi               ; Increment the number of digits (RDI)
    jmp .get_divisor      ; Unconditional jump to the start of the loop

._after:
    pop rax               ; Restore the value of RAX from the stack
    push rdi              ; Save the number of digits on the stack for later

.to_string:
    xor rdx, rdx
    div rcx               ; Divide the number (RAX) by the divisor to get the first digit

    add al, '0'           ; Add the base (48) to the digit to get an ASCII character
    mov [rsi], al         ; Store the character in the string
    inc rsi               ; Increment the string pointer

    push rdx              ; Save the remainder of the number on the stack
    xor rdx, rdx
    mov rax, rcx
    mov rbx, 10
    div rbx               ; Reduce the divisor (RCX) by ten
    mov rcx, rax          ; Store the new divisor in RCX

    pop rax               ; Restore the remainder of the number from the stack

    cmp rcx, 0            ; Check if the divisor has become zero
    jg .to_string         ; If not, repeat the process

    mov byte [rsi + rdx], 0
    pop rdx               ; Restore the number of digits from the stack
    pop rsi               ; Restore RSI to the beginning of the string before returning
    ret
