; ooooo        ooooo oooooooooo.        .o.        .oooooo..o ooo        ooooo 
; `888'        `888' `888'   `Y8b      .888.      d8P'    `Y8 `88.       .888' 
;  888          888   888     888     .8"888.     Y88bo.       888b     d'888  
;  888          888   888oooo888'    .8' `888.     `"Y8888o.   8 Y88. .P  888  
;  888          888   888    `88b   .88ooo8888.        `"Y88b  8  `888'   888  
;  888       o  888   888    .88P  .8'     `888.  oo     .d8P  8    Y     888  
; o888ooooood8 o888o o888bood8P'  o88o     o8888o 8""88888P'  o8o        o888o 

BITS 64

null_terminator equ 0x00
tab             equ 0x09
newline         equ 0x0A
vertical_tab    equ 0x0B
form_feed       equ 0x0C
carriage_return equ 0x0D
space           equ 0x20
minus           equ 0x2D
plus            equ 0x2B

global ft_atoi_base

section .text

; int get_value(const char val, char* base_str, int base)
; {
; 	for (int i = 0; i < base; i++)
; 	{
; 		if (base_str[i] == val || base_str[i] == val)
; 			return i;
; 	}
; 	return -1;
; }
;
; void skip_whitespace(const char** str, int* i)
; {
; 	while (**str)
; 	{
; 		if (**str != ' ' && **str != '\n' && **str != '\t' \
; 		&& **str != '\v' && **str != '\f' && **str != '\r')
; 			return ;
; 		*str++;
; 	}
; }
;
; int skip_sign(const char** str, int* i)
; {
;   int sign = 1;
; 	while (**str)
; 	{
; 		if (**str == '-' || **sign == '+')
; 		{
; 			*str++;
; 			if (**str == '-')
; 				sign = -1;
; 		}
; 		else
; 			return sign;
; 	}
; 	return sign;
; }
;
; int ft_atoi_base(const char *str, char* base_str)
; {
;   int base = strlen(base_str);
; 	int value = 0;
; 	int curr_value = 0;
; 	int sign = 1;
;
; 	skip_whitespace(&str);
; 	sign = skip_sign(&str);
; 	while (*str)
; 	{
; 		value *= base;
; 		curr_value = get_value(*str, base_str, base);
; 		if (curr_value == -1)
; 			return (value * sign);
; 		value += curr_value;
; 		str;
; 	}
; 	return (value * sign);
; }
;
ft_atoi_base: ; rdi: *str, rsi: *base_str
    xor rax, rax ; clear rax, use it as the result value
    xor rcx, rcx; use as a base count
    mov r8d, 1 ; sign
    cmp rsi, 0
    jle .end

.get_base_count:
    cmp byte [rsi + rcx], null_terminator ; current char
    jz .skip_whitespace
    inc rcx
    jmp .get_base_count	

.skip_whitespace:
    cmp byte [rdi], space
    je .loop_whitespace
    cmp byte [rdi], newline
    je .loop_whitespace
    cmp byte [rdi], tab
    je .loop_whitespace
    cmp byte [rdi], vertical_tab
    je .loop_whitespace
    cmp byte [rdi], form_feed
    je .loop_whitespace
    cmp byte [rdi], carriage_return
    je .loop_whitespace
    jmp .check_minus ; no whitespace found check for sign
.loop_whitespace:
    inc rdi
    jmp .skip_whitespace

.set_negative:
    neg r8d ; invert the sign
.skip_sign_loop:
    inc rdi ; increment the string to skip past the sign
.check_minus:
    cmp byte [rdi], minus
    je .set_negative
.check_plus:
    cmp byte [rdi], plus
    je .skip_sign_loop

.main_loop:
    cmp byte [rdi], null_terminator
    je .end
    mul rcx ; multiply the result with the base
    jmp .get_value
.continue_main_loop:
    add rax, rdx ; add the value to the result
    inc rdi ; increment the source string pointer
    jmp .main_loop

.get_value:
    xor rdx, rdx ; used as an index and the representation of the value pointed to by rdi
    mov r9b, [rdi] ; current char
.get_value_loop:
    mov r10b, [rsi + rdx] ; get the current base_str value
    cmp r10b, null_terminator ; check that we've not reached the end of base_str yet
    je .end
    cmp r9b, r10b ; compare to the uppercase base string
    je .continue_main_loop
    inc rdx
    jmp .get_value_loop

.end:
    mul r8d; multiply rax with the sign
    ret
