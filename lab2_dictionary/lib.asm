section .text
global string_length
global print_char
global print_newline
global print_string
global print_error
global print_uint
global print_int
global string_equals
global parse_uint
global parse_int
global read_word
global string_copy
global exit

; желаю не ослепнуть от чтения данного кода

; Принимает код возврата и завершает текущий процесс
exit: 
    mov rax, 60    ;код возврата уже в rdi
    syscall

; Принимает указатель на нуль-терминированную строку, возвращает её длину
string_length:
    xor rax, rax
.loop:
    inc rax
    cmp byte [rdi + rax - 1], 0 ;starts with 1, ends with 1+length-1
    jne .loop
    dec rax
    ret

; Принимает указатель на нуль-терминированную строку, выводит её в stdout
print_string:
    call string_length
    mov rsi, rdi
    mov rdi, 1
    mov rdx, rax
    mov rax, 1
    syscall
    ret

; Принимает код символа и выводит его в stdout
print_char:
    push 0
    push rdi
    mov rdi, rsp
    call print_string
    add rsp, 16
    ret ; как же хочется putchar...;

; Переводит строку (выводит символ с кодом 0xA)
print_newline:
    mov rdi, 0xA
    call print_char
    ret

; Выводит беззнаковое 8-байтовое число в десятичном формате 
; Совет: выделите место в стеке и храните там результаты деления
; Не забудьте перевести цифры в их ASCII коды.
; При div -- rax целая часть, rdx остаток
print_uint:
; когда-то тут был нормальный код  
; проблема была в том, что rcx меняется при syscall!!!

; Выводит знаковое 8-байтовое число в десятичном формате 
print_int:
    test rdi, rdi
    js .neg
    call print_uint
    ret
    .neg:
        push rdi
        mov rdi, "-"
        call print_char
        pop rdi
        neg rdi
        call print_uint
    ret

; Принимает два (rdi, rsi) указателя на нуль-терминированные строки, возвращает 1 если они равны, 0 иначе
string_equals:
	push rbx
	xor rbx, rbx			; counter of symb in strings
	xor rax, rax			; local data to equals
	
  .loop_equal:
	mov cl, byte [rdi+rbx]
	cmp cl, byte [rsi+rbx]
	jnz .eq_err
	
	cmp byte [rdi+rbx], 0
	jz .eq_ok

	inc rbx
	jmp .loop_equal

  .eq_ok:
	mov rax, 1
	jmp .end
  .eq_err:
	mov rax, 0
	jmp .end

  .end:
	pop rbx
	ret


; Читает один символ из stdin и возвращает его. Возвращает 0 если достигнут конец потока
read_char:
    push rdx
    push rdi
    push rsi
    
    xor rax, rax    ; номер системного вызова
    push rax    ; записываем 0 в стек
    xor rdi, rdi    ; адрес чтения (файловый дескриптор)
    mov rsi, rsp    ; адрес записи
    mov rdx, 1    ; длина чтения
    syscall
    pop rax    ; возвращаем символ
    
    pop rsi
    pop rdi
    pop rdx
    ret

; Принимает: адрес начала буфера (rdi), размер буфера (rsi)
; Читает в буфер слово из stdin, пропуская пробельные символы в начале, .
; Пробельные символы это пробел 0x20, табуляция 0x9 и перевод строки 0xA.
; Останавливается и возвращает 0 если слово слишком большое для буфера
; При успехе возвращает адрес буфера в rax, длину слова в rdx.
; При неудаче возвращает 0 в rax
; Эта функция должна дописывать к слову нуль-терминатор
read_word:
  .delete_spaces:
	push rdi
	push rsi
	push rdx	
	call read_char
	pop rdx
	pop rsi
	pop rdi	

	cmp rax, 0x09
	je .delete_spaces
	cmp rax, 0x0A
	je .delete_spaces
	cmp rax, 0x20
	je .delete_spaces
	
  .before_loop:
	xor rdx, rdx
  .read_char_loop:
	cmp rdx, rsi
	je .str_error
	
	cmp rax, 0x00
	je .str_ok
	cmp rax, 0x09
	je .str_ok
	cmp rax, 0x0A
	je .str_ok
	cmp rax, 0x20
	je .str_ok

	mov byte [rdi + rdx], al
	inc rdx
	
	push rdi
	push rsi
	push rdx
	call read_char
	pop rdx
	pop rsi
	pop rdi	

	jmp .read_char_loop

  .str_ok:
	mov byte [rdi + rdx], 0
	mov rax, rdi
	jmp .end
  .str_error:
	xor rax, rax
	jmp .end
  .end:	
 	ret
    

; Принимает указатель (rdi) на строку, пытается
; прочитать из её начала беззнаковое число.
; Возвращает в rax: число, rdx : его длину в символах
; rdx = 0 если число прочитать не удалось
parse_uint:
    push r9
    push r10
    xor rdx, rdx
    xor rax, rax
    mov r10, 10    ; цифра 10 (для умножения)
    
    .loop:
        jmp .check_less
        .checked:
            push rdx
            mul r10
            pop rdx
            mov r9b, byte[rdi + rdx]
            movsx r9, r9b
            add rax, r9
            sub rax, "0"    ; переводим символ из ASCII в цифру
            inc rdx    ; считаем длину числа
        jmp .loop
        
    .end:
    pop r10
    pop r9
    ret
    
    .check_less:
    cmp byte[rdi + rdx], "0"
    jge .check_greater
    jmp .end
    
    .check_greater:
    cmp byte[rdi + rdx], "9"
    jle .checked
    jmp .end




; Принимает указатель на строку (rdi), пытается
; прочитать из её начала знаковое число.
; Если есть знак, пробелы между ним и числом не разрешены.
; Возвращает в rax: число, rdx : его длину в символах (включая знак, если он был) 
; rdx = 0 если число прочитать не удалось
parse_int:
    mov al, byte[rdi]
    cmp al, 2dh
    jz .negative
    call parse_uint
    ret
    
    .negative:
        mov al, byte[rdi + 1]
        test al, al    ; проверяем наличие пробелных символов после знака "-"
        cmp al, 20h
        je .fail_end
        cmp al, 9h
        je .fail_end
        cmp al, 0Ah
        je .fail_end
        inc rdi
        call parse_uint
        neg rax
        inc rdx
        ret
        
    .fail_end:
        xor rax, rax
        ret

; Принимает указатель на строку (rdi), указатель на буфер (rsi) и длину буфера (rdx)
; Копирует строку в буфер
; Возвращает длину строки если она умещается в буфер, иначе 0
string_copy:
    mov al, byte[rdi]    ; небольшой костыль для обработки ctrl + d (пустой строки)
    test al, al
    jnz .continue
    mov rax, [rsi]
    xor [rsi], rax
    xor rax, rax
    ret                ; --- конец костыля ---
    .continue:
    push rcx
    call string_length
    push r8
    cmp rax, rdx
    jnle .not_fit
    mov rcx, rdx
    .loop:
        mov r8, [rdi]
        mov [rsi], r8
        inc rdi
        inc rsi
        loop .loop
    pop r8
    pop rcx
    ret
    .not_fit:
        xor rax, rax
        pop r8
        pop rcx
    ret

; rdi -- указатель на строку
print_error:
	xor rax, rax
	mov rsi, rdi
	call string_length
	mov rdx, rax
	mov rdi, 2
	mov rax, 1
	syscall
	ret
