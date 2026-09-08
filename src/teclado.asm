; teclado.asm - Modulo de Lectura no bloqueante del teclado

leer_teclado:

    pusha

    ; Verificamos si hay alguna tecla disponible en el buffer

    mov ah, 0x01
    int 0x16
    jz .sin_tecla ; Si ZF = 1, no hay tecla presionada y salir

    ; Leer la tecla presiona del buffer
    mov ah, 0x00
    int 0x16 ; AL = Codigo ASCII de la tecla

    ; Guardar el caracter en la variable global
    mov [tecla_presionada], al


.sin_tecla:
    popa
    ret
