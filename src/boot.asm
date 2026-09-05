; boot.asm - Rutina de Bienvenida e Inicialización


mostrar_bienvenida:
    ; Configurar modo de texto 80x25 de color (Limpia la pantalla)
    mov ax, 0x0003
    int 0x10

    ; Imprimir mensaje de bienvenida
    mov si, msg_hola
    call imprimir_char
    ret

esperar_enter:
    mov si, msg_enter
    call imprimir_char

.esperar:
    xor ah, ah
    int 0x16
    cmp al, 13
    jne .esperar
    ret

imprimir_char:
    lodsb ; Carga el siguiente byte de [SI] en AL e incrementa SI
    cmp al, 0 ; ¿Llegamos al final de la cadena (0)?
    je .fin
    mov ah, 0x0E ; Función de teleimpresión INT 10h
    mov bh, 0x00 ; Página 0
    mov bl, 0x0F ; Texto en blanco brillante
    int 0x10
    jmp imprimir_char

.fin:
    ret

msg_hola db '--- Sistema Reloj Bootloader listo ---', 0x0D, 0x0A, 0
msg_enter db 'Presione ENTER para iniciar...', 13, 10, 0