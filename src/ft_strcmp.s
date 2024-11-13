; ooooo        ooooo oooooooooo.        .o.        .oooooo..o ooo        ooooo 
; `888'        `888' `888'   `Y8b      .888.      d8P'    `Y8 `88.       .888' 
;  888          888   888     888     .8"888.     Y88bo.       888b     d'888  
;  888          888   888oooo888'    .8' `888.     `"Y8888o.   8 Y88. .P  888  
;  888          888   888    `88b   .88ooo8888.        `"Y88b  8  `888'   888  
;  888       o  888   888    .88P  .8'     `888.  oo     .d8P  8    Y     888  
; o888ooooood8 o888o o888bood8P'  o88o     o8888o 8""88888P'  o8o        o888o 

BITS64
global ft_strcmp

section .text

ft_strcmp: ; rdi: s1 - rsi: s2
    movsx eax, byte [rdi]
    movsx ecx, byte [rsi]
    inc rsi
    inc rdi
    cmp al, cl ; test if the chars in s1[i] are equal to s2[i]
    jne .end
    test al, al ; test if a null byte has been found
    jnz ft_strcmp
.end:
    sub eax, ecx ; put the right value inside the rax register (eax's extended register)
    ret
