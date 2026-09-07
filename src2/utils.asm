; Módulo: utils.asm
; Descripción: Funciones auxilares de conversión numéricas a texto UTF-16.


bits 64
default rel

global Utils_ByteToUTF16

section .text


; Funcion: Utils_ByteToUTF16
; Descripción: Convierte un byte (0-99) en 2 caracteres UTF-16 con cero a la izquierda.
; Entrada:  CL = Número entero (0 a 99)
;           RDX = Puntero a buffer de salida (al menos 3 WORDs: D1, D2, 0)

Utils_ByteToUTF16:
    movzx ax, cl                ; AX = Número a convertir
    mov bl, 10
    div bl                      ; AL = Decenas (Cociente), AH = Unidades (Residuo)

    ; Convertir Decenas a UTF-16
    add al, '0'
    movzx r8w, al
    mov [rdx], r8w

    ; Convertir Unidades a UTF-16
    add ah, '0'
    movzx r8w, ah
    mov [rdx + 2], r8w

    ; Cero nulo de terminación UTF-16
    mov word [rdx + 4], 0
    ret