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


; Fondo rojo para alarma
fill_screen_red:
    pusha

    mov ax, 0600h
    mov bh, 4Fh       ; fondo rojo + texto blanco brillante
    mov cx, 0000h     ; fila 0, columna 0
    mov dx, 184Fh     ; fila 24, columna 79
    int 10h

    popa
    ret


; para devolverla a lo normal
fill_screen_normal:
    pusha

    mov ax, 0600h
    mov bh, 0Fh       ; fondo negro + texto blanco brillante
    mov cx, 0000h
    mov dx, 184Fh
    int 10h

    popa
    ret