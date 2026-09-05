[ORG 0x7C00] ; Dirección donde BIOS carga el bootloader
[BITS 16] ; Modo real de 16 bits

inicio:
    cli ; Deshabilitar interrupciones
    xor ax, ax ; Limpiar registros de segmento
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00 ; Crear el stack por debajo de 0x7C00
    sti ; Habilitar interrupciones

    ; BIOS deja en DL el disco del boot
    mov [boot_drive], dl

    ; Pantalla de bienvenida
    call mostrar_bienvenida
    call esperar_enter

    ; Se reinicia el sistema del disco antes de leer
    xor ah, ah
    mov dl, [boot_drive]
    int 0x13

    ; Carga app.bin en su espacio
    mov ax, 0x1000
    mov es, ax
    xor bx, bx

    mov ah, 0x02        ; INT 13h: leer sectores
    mov al, 16          ; 16 sectores = 8192 bytes
    mov ch, 0           ; cilindro 0
    mov cl, 2           ; sector 2; sector 1 es el bootloader
    mov dh, 0           ; cabeza 0
    mov dl, [boot_drive]

    int 0x13
    jc disk_error

    ; Transferir el control a la aplicación
    jmp 0x1000:0x0000

disk_error:
    mov si, msg_error
    call imprimir_char

hang:
    cli
    hlt
    jmp hang

boot_drive db 0
msg_error db 13, 10, 'ERROR pa'

%include "boot.asm"

times 510 - ($ - $$) db 0
dw 0xAA55