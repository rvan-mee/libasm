; ooooo        ooooo oooooooooo.        .o.        .oooooo..o ooo        ooooo 
; `888'        `888' `888'   `Y8b      .888.      d8P'    `Y8 `88.       .888' 
;  888          888   888     888     .8"888.     Y88bo.       888b     d'888  
;  888          888   888oooo888'    .8' `888.     `"Y8888o.   8 Y88. .P  888  
;  888          888   888    `88b   .88ooo8888.        `"Y88b  8  `888'   888  
;  888       o  888   888    .88P  .8'     `888.  oo     .d8P  8    Y     888  
; o888ooooood8 o888o o888bood8P'  o88o     o8888o 8""88888P'  o8o        o888o

BITS 64

extern malloc

; list definition
struc   t_list
	a:	resq	1 ; *data
	b:	resq	1 ; *next
endstruc

global ft_list_push_front

section .text

ft_list_push_front: ; rdi: **begin_list, rsi *data
    push r13 ; preserved register
    push r12 ; preserved register
    test rdi, rdi ; null protection
    jz .end
    mov r12, rdi ; save the beginning of the list in a preserved register so malloc wont overwrite it
    mov r13, rsi ; save the data in a preserved register so malloc wont overwrite it
    ; create a new node
    mov rdi, t_list%+_size ; use the size of a node as the argument for malloc
    call malloc wrt ..plt ; create a new head node
    test rax, rax
    jz .end
    mov [rax+a], r13 ; store the data
    mov r11, [r12] ; get the prev head node
    mov [rax+b], r11 ; store the prev head node as the new next pointer
    mov [r12], rax ; store the new node as the head
.end:
    pop r12 ; return register to original state
    pop r13 ; return register to original state
    ret
