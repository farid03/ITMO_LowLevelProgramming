global find_word
%include "lib.inc"
section .text
; rdi - указатель на нуль-термированную строку (ключ), rsi - указатель на начало словаря
find_word: 
    push rdi
    push rsi
    add rsi, 8
    call string_equals
    pop rsi
    pop rdi
    test rax, rax
    jnz .end
    
    mov rsi, [rsi]
    test rsi, rsi
    jne find_word
    ret

    .end:
    mov rax, rsi
    ret

