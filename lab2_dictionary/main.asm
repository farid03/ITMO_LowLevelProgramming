%include "colon.inc"
%include "words.inc"
%include "lib.inc"
global _start
extern find_word

section .data
    word_buffer: times 256 db 0
    
section .rodata
    msg_is_long: db "Введенная строка слишком длинная! Максимальная длина -- 256 символов!", 0
    msg_not_found: db "Введенный ключ отсутсвтует в словаре!", 0

section .text

_start:
    mov rdi, word_buffer
    mov rsi, 256
    call read_word
    cmp rax, 0
    je .is_long

    mov rdi, word_buffer
    mov rsi, first_word
    call find_word
    test rax, rax
    je .not_found
    	
    add rax, 8    ; rax + смещение до следующего элемента
	add rax, rdx
	add rax, 1
	mov rdi, rax
	call print_string
	call print_newline
	call exit
    
.is_long:
    mov rdi, msg_is_long
    jmp .end

.not_found:
    mov rdi, msg_not_found
.end
    call print_error
    call print_newline
    call exit
