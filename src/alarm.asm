setup_alarm:
    push ax
    push ds

    cli

    mov ax, 0
    mov ds, ax

    ; Posición de la int 4Ah, el alarm_handler se mete ahí
    ; Esta guarda el offset donde esté el handler
    mov word [0x0128], alarm_handler

    ; y aquí se se guarda el segmento, onde ta el código pues
    mov ax, cs
    mov word [0x012A], ax

    pop ds
    pop ax

    sti
    ret

alarm_handler:
    push ax
    push ds

    mov ax, cs
    mov ds, ax

    ; Solo si la alarma sigue activa
    cmp byte [alarm_on], 1
    jne .fin

    mov byte [alarm_trigg], 1

.fin:
    pop ds
    pop ax
    iret


alarm:
    push ax
    push bx
    push cx
    push dx
    push ds

    mov ax, cs
    mov ds, ax

    ; se quita toda alarma anterior
    mov ah, 07h
    int 1Ah

    ; horas
    mov al, [alarm_hora]
    call dec_a_bcd
    mov ch, al

    ; minutos
    mov al, [alarm_min]
    call dec_a_bcd
    mov cl, al

    ; segundos siempre 0
    mov dh, 00h

    ; interrupcion
    mov ah, 06h
    int 1Ah

    mov ax, cs
    mov ds, ax

    jc .error

    mov byte [alarm_on], 1
    mov byte [alarm_trigg], 0

    jmp .fin

.error:
    mov byte [alarm_on], 0
    mov byte [alarm_trigg], 0

    pop ax
    ret

.fin:
    pop ds
    pop dx
    pop cx
    pop bx
    pop ax
    ret



cancel_alarm:
    push ax

    ; ah = 07H desactiva las alarmas rtc
    mov ah, 07h
    int 1Ah


    mov byte [alarm_on], 0
    mov byte [alarm_trigg], 0
    mov byte [alarm_hora], 0
    mov byte [alarm_min], 0

    pop ax
    ret

