global _start

section .bss
    input resb 32


section .data
    help: db "Print the string sent as parameter", 10
    .lenHelp: equ $ - help
    usage: db "USAGE : ./asm05 STRING", 10
    .lenUsage: equ $ - usage



section .text
_start:
    mov r13, [rsp]  ; is there the attended arguments ?
    cmp r13, 2
    jne _error



    mov rsi, rsp
    add rsi, 16
    mov rsi, [rsi]
    mov rdi, input    ; keeping first number
    mov rcx, 16
    rep movsb


_exit:
    mov rax, 1
    mov rdi, 1
    mov rsi, input
    mov rdx, 16
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
