global _start

section .data
    msg db "rentrer un entier :",10
    msglen equ $ - msg

    successMsg db "1337", 10
    successMsgLen equ $ - successMsg
    

section .bss
    userinput resb 32

section .text

_start : 

    mov rax, 1
    mov rdi, 1 
    mov rsi, msg
    mov rdx, msglen

    syscall


_stock : 

    mov rax, 0 
    mov rdi, 0
    mov rsi, userinput
    mov rdx, 32

    syscall

_write : 
    mov rax, 1
    mov rdi, 1
    mov rsi, successMsg
    mov rdx, successMsgLen

    syscall

_cmp : 
    mov al, [userinput]
    cmp al, '4'
    jne _fail
    mov al, [userinput+1]
    cmp al, '2'
    jne _fail
    mov al, [userinput+2]
    cmp al, 10
    jne _fail

_success:

    mov rax, 60 
    mov rdi, 0
    
    jmp _quit

_fail : 
    
    mov rax, 60 
    mov rdi, 1

_quit :

    syscall