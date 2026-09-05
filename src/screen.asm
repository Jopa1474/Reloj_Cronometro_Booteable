clear_screen:
    pusha

    mov ax, 0x0003
    int 0x10 

    popa
    ret
    

print_string:
    pusha

.next_char:
    lodsb

    cmp al, 0
    je .done

    mov ah, 0x0E
    mov bh, 0x00
    int 0x10

    jmp .next_char

.done:
    popa
    ret

set_cursor:
    push ax
    push bx

    mov ah, 0x02
    mov bh, 0x00
    int 0x10

    pop bx
    pop ax
    ret