; Archivo main de la tarea 

[ORG 0x7C00] ; Direccion de memoria donde la BIOS carga el bootloader
[BITS 16] ; Modo real de 16 BITS

inicio:
    cli ; Desabilitar interrupciones temporalmente
    xor ax, ax ; AX = 0
    mov ds, ax ; Inicializar segmentos de memoria 
    mov es, ax 
    mov ss, ax 
    mov sp, 0x7C00 ; Inicializar el stack por debajo de 0x7C00
    sti ; Habilitamos las interrupciones

    ; Llamar a la pantalla de bienvenida

bucle_principal:
    jmp bucle_principal

; Archivo para boot
%include "src/bood.asm"

; Relleno estandar para completar 512 bytes del sector de boot
times 510 - ($ - $$) db 0
dw 0xAA55 ;Firma de arranque para el BIOS

