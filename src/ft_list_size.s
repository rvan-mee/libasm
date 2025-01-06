; ooooo        ooooo oooooooooo.        .o.        .oooooo..o ooo        ooooo 
; `888'        `888' `888'   `Y8b      .888.      d8P'    `Y8 `88.       .888' 
;  888          888   888     888     .8"888.     Y88bo.       888b     d'888  
;  888          888   888oooo888'    .8' `888.     `"Y8888o.   8 Y88. .P  888  
;  888          888   888    `88b   .88ooo8888.        `"Y88b  8  `888'   888  
;  888       o  888   888    .88P  .8'     `888.  oo     .d8P  8    Y     888  
; o888ooooood8 o888o o888bood8P'  o88o     o8888o 8""88888P'  o8o        o888o 

BITS 64

; list definition
struc   t_list
	a:	resq	1 ; *data
	b:	resq	1 ; *next
endstruc

global ft_list_size

section .text

ft_list_size: ; rdi: *begin_list
    xor rax, rax
.loop:
    cmp qword rdi, 0
    jz .end
    inc rax
    mov rdi, [rdi+b]
    jmp .loop
.end:
    ret
