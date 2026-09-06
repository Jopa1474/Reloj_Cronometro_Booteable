; rtc.asm - Modulo de Lectura de Reloj en Tiempo Real (RTC)

leer_rtc:
    pusha ; Guardamos los registros generales

    mov ah, 0x02 ; Leemos la hora rtc con la funcion 02h
    int 0x1A ; Llamada al BIOS
    jc .error_rtc ;

    ; Convertir y guardar horas
    mov al, ch 
    call bcd_a_dec
    mov [reloj_horas], al

    ; Convertir y guardar minutos
    mov al, cl
    call bcd_a_dec
    mov [reloj_mins], al

    ; Convertir y guardar los segundos
    mov al, dh
    call bcd_a_dec
    mov [reloj_segs], al

.error_rtc:
    popa ; Restaurar registros
    ret

; Rutina auxiliar, convierte un byte BCD (en AL) a decimal

bcd_a_dec:
    push bx
    mov bl, al
    and bl, 0x0F ; Bl son las unidades
    
    shr al, 4 ; AL son las decenas 
    mov bh, 10
    mul bh ; AX = decenas * 10

    add al, bl ; AL = (decenas * 10) + unidades
    pop bx
    ret

dec_a_bcd:
    push bx

    mov ah, 0
    mov bl, 10
    div bl

    shl al, 4
    or al, ah

    pop bx 
    ret