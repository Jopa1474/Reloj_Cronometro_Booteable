inc_crono:
    
    inc byte [cron_segs]

    cmp byte [cron_segs], 60
    jne fin

    mov byte [cron_segs], 0
    inc byte [cron_mins]

    cmp byte [cron_mins], 60
    jne fin

    mov byte [cron_mins], 0
    inc byte [cron_horas]

fin:
    ret

update_crono_time:

    ; Si está pausado, no hacer nada
    cmp byte [cron_estado], 1
    jne .fin

    ; Ver si cambió el segundo del RTC
    mov al, [reloj_segs]

    cmp al, [cron_ultimo_seg]
    je .fin

    ; Guardar nuevo segundo
    mov [cron_ultimo_seg], al

    call inc_crono

.fin:
    ret

toggle_chrono:
    cmp byte [cron_estado], 0
    je init_chrono

    mov byte [cron_estado], 0
    ret

init_chrono:
    mov byte [cron_estado], 1
    
    mov al, [reloj_segs]
    mov [cron_ultimo_seg], al

    ret

reset_crono:
    mov byte [cron_horas], 0
    mov byte [cron_mins], 0
    mov byte [cron_segs], 0
    ret