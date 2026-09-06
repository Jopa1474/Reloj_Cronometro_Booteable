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

    mov byte [alarm_trigg], 1

    pop ds
    pop ax
    iret


alarm:
    ; se quita lo anterior
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

    jc error

    mov byte [alarm_on], 1
    mov byte [alarm_trigg], 0
    ret

cancel_alarm:
    mov ah, 07h
    int 1Ah

    mov byte [alarm_on], 0
    mov byte [alarm_trigg], 0

    ret

error:
    mov byte [alarm_on], 0
    ret
