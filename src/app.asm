bits 16

start:

    ; preparar segmentos
    push cs
    pop ds
    push cs
    pop es

    call draw_screen


main_loop:

    ; Esto es para que espere 0.1s
    ; Para que no esté actualizando cada ciclo
    mov ah, 86h
    mov cx, 0001h
    mov dx, 86A0h
    int 15h

    ; Actualiza para los relojes y eso
    call update_mode

    ; Se revisa si hay tecla de cambio
    mov ah, 0x01
    int 0x16
    jz main_loop

    mov ah, 0x00
    int 0x16
    call key

    jmp main_loop

update_mode:    
    cmp byte[mode], 0
    je update_watch

    ; TODO: cronometro
    ret

update_watch:
    call show_time
    ret

key:
    cmp al, 'm'
    je mode_switch

    cmp al, "M"
    je mode_switch

    ret

mode_switch:
    cmp byte [mode], 0
    je switch_to_crono

    ; Si ya estaba en crono tons a reloj
    mov byte [mode], 0
    call draw_screen
    ret

switch_to_crono:
    mov byte [mode], 1
    call draw_screen
    ret

draw_screen:
    call clear_screen

    mov si, title
    call print_string

    mov si, newline
    call print_string

    cmp byte [mode], 0
    je clock_mode

    mov si, mode_crono_text
    call print_string

    mov si, crono_time
    call print_string
    ret

clock_mode:
    mov si, mode_reloj_text
    call print_string

    mov si, newline
    call print_string
    
    mov si, reloj_time
    call print_string
    call show_time

    ret

print_bcd:
    push ax
    push bx
    push cx
    push dx

    mov bl, al
    
    ; Decenas (Se hace un shift right de 4)
    mov dl, bl
    mov cl, 4
    shr dl, cl
    add dl, '0'

    mov al, dl
    mov ah, 0x0E
    int 0x10

    ; Unidades
    mov dl, bl
    and dl, 0X0F 
    add dl, '0'

    mov al, dl
    mov ah, 0x0E
    int 0x10

    pop dx
    pop cx
    pop bx
    pop ax
    ret


show_time:

    mov dh, 6
    mov dl, 6
    call set_cursor


    mov ah, 0x02
    int 0x1A

    mov al, ch
    call print_bcd

    mov al, ':'
    mov ah, 0x0E
    int 0x10

    mov al, cl
    call print_bcd

    mov al, ':'
    mov ah, 0x0E
    int 0x10

    mov al, dh
    call print_bcd

    ret




;################## Variables y cosas así ################


mode db 0    ; se inicia en modo reloj, 1 es cronometro

title db '========================================', 13, 10
      db '        RELOJ / CRONOMETRO', 13, 10
      db '========================================', 13, 10, 0


mode_reloj_text db 'Modo: RELOJ', 13, 10, 0
mode_crono_text db 'Modo: CRONOMETRO', 13, 10, 0

reloj_time db 'Hora: ', 0
crono_time db 'Cronometro: ', 0

newline db 13, 10, 0

%include "screen.asm"