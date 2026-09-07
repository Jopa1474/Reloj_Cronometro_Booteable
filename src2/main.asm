; Módulo: main.asm
; Descripción: Punto de entrada ejecutable y bucle principal del sistema UEFI.

bits 64
default rel

global efi_main

extern Screen_Init
extern Screen_Clear
extern Screen_SetColor
extern Screen_DrawWelcome
extern Screen_DrawHeader
extern Screen_DrawFooter
extern Teclado_ReadChar
extern RTC_GetTime
extern Utils_ByteToUTF16

section .data
    ; Etiquetas fijas para la visualización del estado
    str_rtc_lbl:    dw __utf16__(`   HORA ACTUAL : `), 0
    str_crono_lbl:  dw __utf16__(` | CRONO: 00:00:00`), 0
    str_alarm_lbl:  dw __utf16__(` | ALARMA: OFF`), 0
    str_dos_puntos: dw __utf16__(`:`), 0
    str_nl:         dw __utf16__(`\r\n`), 0

    ; Buffers de texto UTF-16 para almacenar los dígitos convertidos
    buf_hh: dw 0, 0, 0
    buf_mm: dw 0, 0, 0
    buf_ss: dw 0, 0, 0

    ; Control de sincronización por segundo
    ultimo_seg: db 0xFF

section .text

; Función principal del ejecutable UEFI.
efi_main:
    sub rsp, 56
    mov r12, rdx                ; Guarda la tabla del sistema proporcionada por UEFI.

    ; Inicializa y limpia la pantalla antes del mensaje de bienvenida.
    call Screen_Init
    call Screen_Clear
    call Screen_DrawWelcome

; Espera la interacción inicial del usuario para comenzar la ejecución.
.esperar_inicio:
    call Teclado_ReadChar
    test rax, rax
    jz .esperar_inicio

; Bucle continuo de procesamiento de interfaz y reloj.
.loop_principal:
    ; Verifica la lectura del teclado para detectar salida con la tecla ESC.
    call Teclado_ReadChar
    cmp rdx, 0x17               ; Código para la tecla ESC.
    je .salir

    ; Obtiene el tiempo actual desde el módulo RTC.
    call RTC_GetTime

    ; Evalúa si transcurrió un segundo completo antes de refrescar la pantalla.
    cmp dh, [ultimo_seg]
    je .loop_principal
    mov [ultimo_seg], dh

    ; Convierte las horas de BCD o binario a texto UTF-16.
    push rcx
    push rdx

    mov cl, ch
    lea rdx, [buf_hh]
    call Utils_ByteToUTF16

    pop rdx
    pop rcx
    push rdx
    push rcx

    ; Convierte los minutos a texto UTF-16.
    lea rdx, [buf_mm]
    call Utils_ByteToUTF16

    pop rcx
    pop rdx

    ; Convierte los segundos a texto UTF-16.
    mov cl, dh
    lea rdx, [buf_ss]
    call Utils_ByteToUTF16

    ; Refresca la pantalla limpiando y reconstruyendo la interfaz.
    call Screen_Clear
    call Screen_DrawHeader

    ; Renderiza la hora calculada en color amarillo y blanco.
    mov rdx, 0x0E
    call Screen_SetColor

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_rtc_lbl]
    mov r8, [rax + 8]
    call r8

    mov rdx, 0x0F               ; Texto blanco para los valores numéricos.
    call Screen_SetColor

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [buf_hh]
    mov r8, [rax + 8]
    call r8

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_dos_puntos]
    mov r8, [rax + 8]
    call r8

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [buf_mm]
    mov r8, [rax + 8]
    call r8

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_dos_puntos]
    mov r8, [rax + 8]
    call r8

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [buf_ss]
    mov r8, [rax + 8]
    call r8

    ; Dibuja los marcadores de posición para el cronómetro y la alarma.
    mov rdx, 0x07               ; Color gris.
    call Screen_SetColor

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_crono_lbl]
    mov r8, [rax + 8]
    call r8

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_alarm_lbl]
    mov r8, [rax + 8]
    call r8

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_nl]
    mov r8, [rax + 8]
    call r8

    ; Dibuja las opciones de control en la parte inferior.
    call Screen_DrawFooter

    jmp .loop_principal

; Procedimiento de salida limpia del programa.
.salir:
    call Screen_Clear
    xor rax, rax
    add rsp, 56
    ret