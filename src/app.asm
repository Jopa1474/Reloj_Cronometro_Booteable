[BITS 16]

start:

    ; Se carga la app en 0x1000:0000

    mov ax, cs
    mov ds, ax
    mov es, ax

    ; Stack de la aplicación
    mov ax, 0x9000
    mov ss, ax
    mov sp, 0xFFFE

    call leer_rtc
    call draw_screen


main_loop:

    ; Esto es para que espere 0.1s
    ; Para que no esté actualizando cada ciclo
    mov ah, 86h
    mov cx, 0001h
    mov dx, 86A0h
    int 15h

    call leer_rtc

    ; Actualiza según el modo
    cmp byte [modo_actual], 0
    je update_clock

    jmp update_crono

update_clock:    
    call show_time
    jmp hay_teclado

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

    cmp al, "M"
    je mode_switch

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
    ret

print_2digits:
    push ax
    push bx
    push dx

    xor ah, ah
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




;################## Variables y cosas así ################


mode db 0    ; se inicia en modo reloj, 1 es cronometro

title db '========================================', 13, 10
      db '        RELOJ / CRONOMETRO', 13, 10
      db '========================================', 13, 10, 0


mode_reloj_text db 'Modo: RELOJ', 0
mode_crono_text db 'Modo: CRONOMETRO', 0

reloj_time db 'Hora: ', 0
crono_time db 'Cronometro: ', 0

; Módulos y las variables
%include "defin.inc"
%include "rtc.asm"
%include "teclado.asm"
%include "screen.asm"