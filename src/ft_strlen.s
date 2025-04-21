; ooooo        ooooo oooooooooo.        .o.        .oooooo..o ooo        ooooo 
; `888'        `888' `888'   `Y8b      .888.      d8P'    `Y8 `88.       .888' 
;  888          888   888     888     .8"888.     Y88bo.       888b     d'888  
;  888          888   888oooo888'    .8' `888.     `"Y8888o.   8 Y88. .P  888  
;  888          888   888    `88b   .88ooo8888.        `"Y88b  8  `888'   888  
;  888       o  888   888    .88P  .8'     `888.  oo     .d8P  8    Y     888  
; o888ooooood8 o888o o888bood8P'  o88o     o8888o 8""88888P'  o8o        o888o 

BITS 64
global ft_strlen
global ft_strlen_optimized

section .text

; non-optimized version
ft_strlen: ; rdi: str
    mov rax, rdi
.loop:
    cmp byte [rax], 0
    je .end
    inc rax
    jmp .loop
.end:
    sub rax, rdi ; subtract the starting address from the index of the null char
    ret


; optimized version based on: https://github.com/lattera/glibc/blob/master/string/strlen.c
; note: this is by far not the fastest possible strlen, instructions like "pcmpistri" are a lot faster,
; this was just a fun exercise to do.

; align rdi pointer by checking one byte at a time
; if null is found do an early return

; load 8 bytes (word) at a time into a register
; do bitmagic on the register to check if a byte contains null
; if a null byte is found return the offset from the starting value to there

; Bitmagic explanation:
; for simplicity, we're only using 4 bytes instead of 8
; lets take as an example the bytes "0xFF 0x4E 0x00 0x5D"
; now lets turn these into a bit representation:
; "0b11111111 0b01001110 0x00000000 0b01011101"
;
; these are same values after we invert the word using a NOT operation,
; we need it for possible misfires later on where a values like 0x81 (0b10000001) could cause a false positive
; "0b00000000 0b10110001 0b11111111 0b10100010"
;
; now lets define the lomagic and himagic:
; hi: "0b10000000 0b10000000 0b10000000 0b10000000"
; lo: "0b00000001 0b00000001 0b00000001 0b00000001"
;
; lets go step by step through the instructions
; the first operation is:
; "0b11111111 0b01001110 0b00000000 0b01011101"
; "0b00000001 0b00000001 0b00000001 0b00000001"
; SUB
; the resulting value will be:
; "0b11111110 0b01001101 0b11111111 0b01011100"
;
; next up we will AND the inverted word's value to prevent misfires:
; "0b11111110 0b01001101 0b11111111 0b01011100"
; "0b00000000 0b10110001 0b11111111 0b10100010"
; AND
; the resulting value will be:
; "0b00000000 0b00000001 0b11111111 0b00000000"
;
; lastly we will have to do an AND operation using the himagic:
; "0b00000000 0b00000001 0b11111111 0b00000000"
; "0b10000000 0b10000000 0b10000000 0b10000000"
; AND
; the resulting value will be:
; "0b00000000 0b00000000 0b10000000 0b00000000"
; the byte containing null will be the only byte left that contains a 1 bit

%define himagic r8
%define lomagic r9
%define longword r10
%define longword_not r11

ft_strlen_optimized: ; rdi: str
    mov rax, rdi ; keep the original address inside rdi
    mov rcx, rax
    and rcx, 7 ; use rcx to keep track of how many bytes we need to pass till we're aligned
    jz .aligned
.align:
    cmp byte [rax], 0
    je .end
    inc rax
    dec rcx
    jnz .align
.aligned:
    mov himagic, 0x8080808080808080
    mov lomagic, 0x0101010101010101
.aligned_loop:
    mov longword, [rax]
    mov longword_not, longword
    not longword_not
    sub longword, lomagic
    and longword, longword_not
    and longword, himagic
    jnz .found_null
    add rax, 8
    jmp .aligned_loop
.found_null:
    cmp byte [rax], 0
    je .end
    inc rax
    jmp .found_null
.end:
    sub rax, rdi ; subtract the starting address from the index of the null char
    ret
