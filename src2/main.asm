; ==============================================================================
; MÓDULO: main.asm
; DESCRIPCIÓN: Prueba interactiva de captura de teclado en UEFI.
; ==============================================================================

bits 64
default rel

global efi_main

extern Screen_Init
extern Screen_Clear
extern Screen_SetColor
extern Screen_DrawWelcome
extern Screen_DrawTitle
extern Screen_DrawControls
extern Teclado_ReadChar

section .data
    str_ready:   dw __utf16__(`[SISTEMA LISTO] Presione M, C, R, A, X o ESC para probar...\r\n\r\n`), 0
    str_pres:    dw __utf16__(`Tecla detectada: `), 0
    str_esc:     dw __utf16__(`[ESC] Saliendo del programa...\r\n`), 0
    str_nl:      dw __utf16__(`\r\n`), 0

    ; Buffer UTF-16 para imprimir un solo carácter: [Carácter, Nulo]
    char_buf:    dw 0, 0

section .text

efi_main:
    sub rsp, 56
    mov r12, rdx                ; Guardar SystemTable en R12

    ; 1. Inicialización de Consola
    call Screen_Init
    call Screen_Clear

    ; 2. Pantalla de Bienvenida
    call Screen_DrawWelcome

    ; Esperar tecla inicial para continuar
.esperar_inicio:
    call Teclado_ReadChar
    test rax, rax
    jz .esperar_inicio

    ; 3. Limpiar e imprimir Interfaz Principal
    call Screen_Clear
    call Screen_DrawTitle

    mov rdx, 0x0E               ; Amarillo
    call Screen_SetColor

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_ready]
    mov r8, [rax + 8]
    call r8

    call Screen_DrawControls

    ; 4. Bucle principal de prueba de Teclado
.loop_teclado:
    call Teclado_ReadChar

    ; Validar si se presionó ESC (ScanCode = 0x17)
    cmp rdx, 0x17
    je .salir

    ; Verificar si RAX tiene un carácter imprimible (distinto de 0)
    test rax, rax
    jz .loop_teclado            ; Si es 0, volver a consultar (no bloqueante)

    ; Si hay un carácter, lo preparamos para imprimir
    mov [char_buf], ax          ; Almacenar el carácter de 16 bits en el buffer

    ; Imprimir encabezado: "Tecla detectada: "
    mov rdx, 0x0A               ; Verde claro
    call Screen_SetColor

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_pres]
    mov r8, [rax + 8]
    call r8

    ; Imprimir el carácter presionado
    mov rdx, 0x0F               ; Blanco brillante
    call Screen_SetColor

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [char_buf]
    mov r8, [rax + 8]
    call r8

    ; Salto de línea
    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_nl]
    mov r8, [rax + 8]
    call r8

    jmp .loop_teclado

.salir:
    mov rdx, 0x0C               ; Rojo claro
    call Screen_SetColor

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_esc]
    mov r8, [rax + 8]
    call r8

    call Screen_Clear
    xor rax, rax
    add rsp, 56
    ret