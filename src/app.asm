[BITS 16]

start:
    cli

    ; Se carga la app en 0x1000:0000

    ; Esto para que todo esté igual en el code segment
    mov ax, cs
    mov ds, ax
    mov es, ax

    ; Stack de la aplicación
    mov ax, 0x9000
    mov ss, ax
    mov sp, 0xFFFE

    sti

    call leer_rtc
    call draw_screen
    call setup_alarm


main_loop:

    ; Esto es para que espere 0.1s
    ; Para que no esté actualizando cada ciclo
    mov ah, 86h
    mov cx, 0001h
    mov dx, 86A0h
    int 15h

    ; Revisa si se triggereó la alarma
    cmp byte [alarm_trigg], 1
    je show_alarm

    call leer_rtc
    call update_crono_time

    ; Actualiza según el modo
    cmp byte [modo_actual], 0
    je update_clock

    jmp update_crono


update_clock:    
    call show_time
    jmp hay_teclado

crono_inc:
    call inc_crono
    ret

update_crono:
    call show_crono
    jmp hay_teclado

hay_teclado:
    call leer_teclado

    mov al, [tecla_presionada]

    ; Si vale 0, no hay tecla nueva
    cmp al, 0
    je main_loop

    ; reiniciar la tecla
    mov byte [tecla_presionada], 0

    call key

    jmp main_loop

key:
    cmp al, 'm'
    je mode_switch

    cmp al, 'M'
    je mode_switch

    cmp al, 'c'
    je toggle_chrono

    cmp al, 'C'
    je toggle_chrono

    cmp al, 'r'
    je reset_crono

    cmp al, 'R'
    je reset_crono

    cmp al, 'a'
    je get_alarm

    cmp al, 'A'
    je get_alarm

    cmp al, 'x'
    je cancel_alarm

    cmp al, 'X'
    je cancel_alarm

    ret

mode_switch:
    cmp byte [modo_actual], 0
    je switch_to_crono

    ; Si ya estaba en crono tons a reloj
    mov byte [modo_actual], 0
    call draw_screen
    ret

switch_to_crono:
    mov byte [modo_actual], 1
    call draw_screen
    ret

draw_screen:
    call clear_screen

    mov si, title
    call print_string

    mov dh, 4
    mov dl, 0
    call set_cursor

    cmp byte [modo_actual], 0
    je clock_mode

    mov si, mode_crono_text
    call print_string
    
    mov dh, 6
    mov dl, 0
    call set_cursor
    mov si, crono_time
    call print_string

    call show_crono
    call show_keys
    ret

clock_mode:
    mov si, mode_reloj_text
    call print_string
    
    mov dh, 6
    mov dl, 0
    call set_cursor

    mov si, reloj_time
    call print_string

    call show_time
    call show_keys
    ret

print_2digits:
    push ax
    push bx
    push dx

    mov ah, 0
    mov bl, 10
    div bl

    ; AL = decenas
    ; AH = unidades

    mov dl, ah

    add al, '0'
    mov ah, 0x0E
    mov bh, 0
    int 0x10

    mov al, dl
    add al, '0'
    mov ah, 0x0E
    mov bh, 0
    int 0x10

    pop dx
    pop bx
    pop ax
    ret


show_time:

    mov dh, 6
    mov dl, 6
    call set_cursor

    mov al, [reloj_horas]
    call print_2digits

    mov al, ':'
    mov ah, 0x0E
    int 0x10

    mov al, [reloj_mins]
    call print_2digits

    mov al, ':'
    mov ah, 0x0E
    int 0x10

    mov al, [reloj_segs]
    call print_2digits

    ret

show_crono:

    mov dh, 6
    mov dl, 12
    call set_cursor

    mov al, [cron_horas]
    call print_2digits

    mov al, ':'
    mov ah, 0x0E
    int 0x10

    mov al, [cron_mins]
    call print_2digits

    mov al, ':'
    mov ah, 0x0E
    int 0x10

    mov al, [cron_segs]
    call print_2digits

    ret

show_alarm:
    call clear_screen

    mov dh, 10
    mov dl, 30
    call set_cursor

    mov si, alarm_text
    call print_string

    ; esperar una tecla
    mov ah, 00h
    int 16h

    call cancel_alarm
    call draw_screen

    jmp main_loop

leer_digito:
    mov ah, 00h
    int 16h

    cmp al, '0'
    jb leer_digito

    cmp al, '9'
    ja leer_digito

    ; mostrar el número escrito
    mov ah, 0Eh
    int 10h

    sub al, '0'

    ret

get_alarm:

    call clear_screen

    mov si, alarm_text2
    call print_string

    ; Se guardan los digitos de la alarma
    call leer_digito
    mov [alarm_d1], al

    call leer_digito
    mov [alarm_d2], al

    mov al, ':'
    mov ah, 0Eh
    int 10h

    call leer_digito
    mov [alarm_d3], al

    call leer_digito
    mov [alarm_d4], al

    ; Se acomodan y se ponen juntas y así
    ; Las horas
    mov al, [alarm_d1]
    mov bl, 10
    mul bl
    add al, [alarm_d2]

    mov [alarm_hora], al

    ; minutos

    mov al, [alarm_d3]
    mov bl, 10
    mul bl
    add al, [alarm_d4]

    mov [alarm_min], al

    call alarm
    call draw_screen
    ret

show_keys:
    mov dh, 10
    mov dl, 0
    call set_cursor

    mov si, controls_text
    call print_string
    ret

;################## Variables y cosas así ################

title db '========================================', 13, 10
      db '        RELOJ / CRONOMETRO', 13, 10
      db '========================================', 13, 10, 0


mode_reloj_text db 'Modo: RELOJ', 0
mode_crono_text db 'Modo: CRONOMETRO', 0
alarm_text db '*** !!!ALARMAAAAAAAAa!!! ***', 0
alarm_text2 db 'Ingrese la alarma HH:MM: ', 0
alarm_error db 13, 10, 'Hora invalida', 0

reloj_time db 'Hora: ', 0
crono_time db 'Cronometro: ', 0

controls_text db '[M] Cambiar modo', 13, 10
              db '[C] Iniciar/Pausar cronometro', 13, 10
              db '[R] Reiniciar cronometro', 13, 10
              db '[A] Configurar alarma', 13, 10
              db '[X] Cancelar alarma', 13, 10

; Módulos y las variables
%include "defin.inc"
%include "rtc.asm"
%include "teclado.asm"
%include "screen.asm"
%include "chrono.asm"
%include "alarm.asm"