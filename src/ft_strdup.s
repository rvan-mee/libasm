; ooooo        ooooo oooooooooo.        .o.        .oooooo..o ooo        ooooo 
; `888'        `888' `888'   `Y8b      .888.      d8P'    `Y8 `88.       .888' 
;  888          888   888     888     .8"888.     Y88bo.       888b     d'888  
;  888          888   888oooo888'    .8' `888.     `"Y8888o.   8 Y88. .P  888  
;  888          888   888    `88b   .88ooo8888.        `"Y88b  8  `888'   888  
;  888       o  888   888    .88P  .8'     `888.  oo     .d8P  8    Y     888  
; o888ooooood8 o888o o888bood8P'  o88o     o8888o 8""88888P'  o8o        o888o 

BITS64
global ft_strdup
extern malloc
extern ft_strlen
extern ft_strcpy

section .text

ft_strdup:; rdi: str
    push rbx
    mov rbx, rdi
    call ft_strlen
    inc rax
    mov rdi, rax ; set strlen + 1 as the argument for malloc
    call malloc
    test rax, rax
    jz .end
    mov rdi, rax ; set the newly allocated memory inside the dest
    mov rsi, rbx ; set the origional string inside src
    call ft_strcpy
.end:
    pop rbx
    ret
