; ooooo        ooooo oooooooooo.        .o.        .oooooo..o ooo        ooooo 
; `888'        `888' `888'   `Y8b      .888.      d8P'    `Y8 `88.       .888' 
;  888          888   888     888     .8"888.     Y88bo.       888b     d'888  
;  888          888   888oooo888'    .8' `888.     `"Y8888o.   8 Y88. .P  888  
;  888          888   888    `88b   .88ooo8888.        `"Y88b  8  `888'   888  
;  888       o  888   888    .88P  .8'     `888.  oo     .d8P  8    Y     888  
; o888ooooood8 o888o o888bood8P'  o88o     o8888o 8""88888P'  o8o        o888o 

BITS 64
extern __errno_location
global ft_write

section .text

ft_write:
	push r12 ; save the caller's value on the stack
	mov rax, 1 ; syscall write
	syscall
	cmp rax, 0
	jl .error
	pop r12 ; restore r12 to the caller's value
	ret ; return the amounts of bytes written

.error:
	mov r12, rax ; temp store value in the r12 register
	neg r12 ; invert the return value of the syscall to get the correct errno
	call __errno_location
	mov [rax], r12 ; store the value inside errno
	mov rax, -1 ; return -1
	pop r12 ; restore r12 to the caller's value
	ret
