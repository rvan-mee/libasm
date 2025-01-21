; ooooo        ooooo oooooooooo.        .o.        .oooooo..o ooo        ooooo 
; `888'        `888' `888'   `Y8b      .888.      d8P'    `Y8 `88.       .888' 
;  888          888   888     888     .8"888.     Y88bo.       888b     d'888  
;  888          888   888oooo888'    .8' `888.     `"Y8888o.   8 Y88. .P  888  
;  888          888   888    `88b   .88ooo8888.        `"Y88b  8  `888'   888  
;  888       o  888   888    .88P  .8'     `888.  oo     .d8P  8    Y     888  
; o888ooooood8 o888o o888bood8P'  o88o     o8888o 8""88888P'  o8o        o888o 

BITS 64

struc   t_list
	a:	resq	1 ; *data
	b:	resq	1 ; *next
endstruc

global ft_list_sort

section .text

; bubble sorting the list
; for (t_list* count = *begin_list; count != NULL; start = start->next)
; {
;   for(t_list* curr = *begin_list; curr->next != NULL; curr = curr->next)
;   {
;       if(compare(curr, curr->next) > 0)
;           swap_data(curr, curr->next);
;   }
; }
ft_list_sort: ; rdi: **begin_list, rsi: *compare_func
    push r12 ; head node of the list
    push r13 ; current node
    push r14 ; next node
    push r15 ; count node
    push rbp ; compare func
    test rdi, rdi
    jz .end
    test rsi, rsi
    jz .end
    mov r12, [rdi] ; set r12 equal to the head node of the list
    test r12, r12
    jz .end
    mov rbp, rsi ; set the compare function pointer
    mov r15, r12 ; set the counting node for the bubble sort to the start/head node
    mov r13, r12 ; set current node
    jmp .sort_loop

.move_to_next_iteration: ; loop from start to end of the list to bubble sort it
    mov r15, [r15+b] ; set the r15 (count) to the next node
    test r15, r15
    jz .end
    mov r13, r12 ; set current node to the start of the list

.sort_loop: ; loop through the entire list calling the compare function and swapping the data when necessary
    mov r14, [r13+b] ; set the next node
    test r14, r14
    jz .move_to_next_iteration
    mov rdi, r13 ; set current node as argument 1
    mov rsi, r14 ; set next node as argument 2
    call rbp
    test rax, rax
    jle .move_to_next__node
    ; if the compare function returns > 0 we have to swap the data 
    mov r8, [r13+a] ; get the data from the current node
    mov r9, [r14+a] ; get the data from the next node
    mov [r13+a], r9 ; move data from next into current
    mov [r14+a], r8 ; move data from current into next

.move_to_next__node:
    mov r13, [r13+b] ; set current node to the next node
    jmp .sort_loop

.end:
    pop rbp
    pop r15
    pop r14
    pop r13
    pop r12
    ret
