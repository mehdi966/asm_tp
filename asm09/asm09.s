global _start 

section .data
    help: db "Convert a number to hex (-h) or binary (-b)", 10
    .lenHelp: equ $ - help
    usage: db "USAGE : ./asm09 [-b] NUMBER", 10
    .lenUsage: equ $ - usage

section .bss
    nb resb 32
    string resb 32
    conversion resb 1

section .text
_start:

    ; Check the number of arguments
    mov r13, [rsp]        ; r13 = argc
    cmp r13, 2            ; if less than 2 arguments, show error
    jl _error

    ; Default to hex if no flag is provided
    mov byte [conversion], 0  ; default to hex

    ; Check if the first argument is a flag (-b or -h)
    mov rsi, rsp
    add rsi, 16           ; rsi = argv[1]
    mov rsi, [rsi]
    mov al, [rsi]
    cmp al, '-'
    jne ._getNumberDirect ; if not '-', jump to directly get the number

    ; Check if the flag is -b or -h
    mov al, [rsi + 1]
    cmp al, 'b'
    je ._isBinary
    cmp al, 'h'
    je ._isHex
    jmp _error            ; if not -b or -h, show error

._isBinary:
    mov byte [conversion], 1  ; set conversion to binary
    ; Move to the next argument (the number)
    mov rsi, rsp
    add rsi, 24           ; rsi = argv[2]
    mov rsi, [rsi]
    jmp ._getNumber

._isHex:
    mov byte [conversion], 0  ; set conversion to hex
    ; Move to the next argument (the number)
    mov rsi, rsp
    add rsi, 24           ; rsi = argv[2]
    mov rsi, [rsi]
    jmp ._getNumber

._getNumberDirect:
    ; If no flag, treat the first argument as the number
    mov rsi, rsp
    add rsi, 16           ; rsi = argv[1]
    mov rsi, [rsi]

._getNumber:
    ; Get the number argument
    mov rdi, nb
    mov rcx, 32
    rep movsb             ; copy the number to nb

    xor rdi, rdi
    mov r8, 0

convert:
    mov al, [nb + rdi]    ; convert the number from string to decimal
    cmp al, 0
    je doneConvert

    cmp rax, '0'          ; check if it's a valid digit
    jl _error
    cmp rax, '9'
    jg _error

    sub rax, 48           ; convert ASCII to decimal
    imul r8, 10           ; build the number
    add r8, rax
    
    inc rdi
    jmp convert

doneConvert:

    ; Choose conversion type (hex or binary)
    mov al, [conversion]
    cmp al, 0
    je ._convertHex
    jne ._convertBin

._convertHex:
    mov rcx, 16           ; divide by 16 for hex
    jmp ._choosen

._convertBin:
    mov rcx, 2            ; divide by 2 for binary

._choosen:
    mov rax, r8           ; rax = number to convert

loop:
    xor rdx, rdx          ; clear rdx for division
    div rcx               ; divide rax by rcx
    push rdx              ; save remainder
    inc r10               ; count digits
    cmp rax, 0            ; if quotient is 0, we're done
    je done

    jmp loop

done:
    mov r13, r10          ; save digit count
    inc r13               ; add 1 for null terminator
    xor rdi, rdi
    mov rdi, string

addToString:
    pop r11               ; get remainder
    cmp r11, 10           ; check if it's a letter or number
    jb ._dec
    jae ._ascii

._dec:
    add r11, '0'          ; convert to ASCII digit
    jmp ._store

._ascii:
    add r11, 55           ; convert to ASCII letter (a-f)

._store:
    mov [rdi], r11        ; store the character
    inc rdi
    dec r10
    cmp r10, 0
    je _end
    jmp addToString

_end:
    mov byte [rdi], 0     ; null-terminate the string
    
    ; Print the result
    mov rsi, string
    mov rdi, 1
    mov rax, 1
    mov rdx, r13
    syscall

    ; Exit
    mov rax, 60
    mov rdi, 0
    syscall

_error:
    ; Print help message
    mov rax, 1
    mov rdi, 1
    mov rsi, help
    mov rdx, help.lenHelp
    syscall
    
    ; Print usage message
    mov rax, 1
    mov rdi, 1
    mov rsi, usage
    mov rdx, usage.lenUsage
    syscall

    ; Exit with error
    mov rax, 60
    mov rdi, 1
    syscall
