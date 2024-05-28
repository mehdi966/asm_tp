global _start

section .text
    
_start : 
    mov rax, 1
    mov rdi, 1 
    mov rsi, msg
    mov rdx, msglen

    syscall

    mov rax, 60 
    xor rdi, rdi 

    syscall

section .data 
    msg : db "1337"
    msglen: equ $ - msg