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

    ; Pantalla de bienvenida
    call mostrar_bienvenida

; Bucle principal de la aplicación
bucle_principal:
    jmp bucle_principal

; Archivos de inclusión
%include "src/defin.inc"
%include "src/boot.asm"

; Relleno y firma de arranque exacta
times 510 - ($ - $$) db 0
dw 0xAA55