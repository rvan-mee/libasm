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

extern free

global ft_list_remove_if

section .text

; void	ft_list_remove_if(t_list **begin_list, void *data_ref, int (*cmp)())
; {
; 	t_list	*remove;
; 	t_list	*current;

; 	current = *begin_list;
; 	while (current && current->next)
; 	{
; 		if ((*cmp)(current->next->data, data_ref) == 0)
; 		{
; 			remove = current->next;
; 			current->next = current->next->next;
; 			free(remove);
; 		}
; 		current = current->next;
; 	}
; 	current = *begin_list;
; 	if (current && (*cmp)(current->data, data_ref) == 0)
; 	{
; 		*begin_list = current->next;
; 		free(current);
; 	}
; }
ft_list_remove_if: ; rdi: **begin_list, rsi: *data_ref, rdx: *compare_func, rcx: *free_func
    push r12 ; begin list
    push r13 ; compare func
    push r14 ; current node
    push r15 ; next node
    push rbx ; data_ref
    push rbp ; free_func
    push rdi ; extra push for stack alignment in case the free_func function needs to be aligned
    test rdi, rdi
    jz .end
    test rdx, rdx
    jz .end
    mov rbp, rcx ; set free_func
    mov rbx, rsi ; set data_ref
    mov r12, rdi ; set begin list
    mov r13, rdx ; set compare_func
    mov r14, [r12] ; set current
    test r14, r14
    jz .end

.loop:
    test r14, r14
    jz .check_head
    mov r15, [r14+b] ; set next node
    test r15, r15
    jz .check_head
    mov rdi, [r15+a] ; set next node as first argument
    mov rsi, rbx ; set data_ref as second argument
    call r13
    test eax, eax ; check return value
    jz .remove_next_node
    mov r14, r15 ; set current node to next
    jmp .loop

.remove_next_node:
    mov rdi, [r15+a] ; set the data of the next node as argument for the free_func
    call rbp
    mov rdi, r15 ; set the next node as the argument for free
    mov r15, [r15+b] ; set the next node to next->next
    mov [r14+b], r15 ; set the current->next to next->next 
    call free wrt ..plt
    jmp .loop

.check_head:
    mov rdi, [r12] ; get the head node
    test rdi, rdi ; NULL protection
    jz .end
    mov rdi, [rdi+a] ; set head node's data as first argument
    mov rsi, rbx ; set data_ref as second argument
    call r13
    test eax, eax
    jnz .end
    mov r8, [r12] ; get the current head node
    mov rdi, [r8+a] ; set the data of the head node as argument for the free_func
    call rbp
    mov rdi, [r12] ; get the current head node
    mov r15, [rdi+b] ; set the next node
    mov [r12], r15 ; set the next node as the new head
    call free wrt ..plt

.end:
    pop rdi
    pop rbp
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    ret
