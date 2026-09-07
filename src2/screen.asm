; Módulo: screen.asm
; Descripción: Funciones de renderizado, manejo de color e interfaz de usuario UEFI.

bits 64
default rel

global Screen_Init
global Screen_Clear
global Screen_SetColor
global Screen_DrawWelcome
global Screen_DrawHeader
global Screen_DrawFooter

section .data
    ; Cadenas de texto para la pantalla de bienvenida
    str_welcome1: dw __utf16__(`====================================================\r\n`), 0
    str_welcome2: dw __utf16__(`   INSTITUTO TECNOLOGICO DE COSTA RICA - CE4303    \r\n`), 0
    str_welcome3: dw __utf16__(`     TAREA 1: RELOJ / CRONOMETRO BOOTEABLE UEFI     \r\n`), 0
    str_welcome4: dw __utf16__(`====================================================\r\n\r\n`), 0
    str_welcome5: dw __utf16__(`Presione [ENTER] o cualquier tecla para iniciar...\r\n`), 0

    ; Cadenas de texto para la maquetación principal
    str_marco:     dw __utf16__(`====================================================\r\n`), 0
    str_titulo:    dw __utf16__(`             RELOJ / CRONOMETRO CON ALARMA          \r\n`), 0
    str_lbl_modo:  dw __utf16__(`   MODO ACTIVO : [RELOJ PRINCIPAL]\r\n\r\n`), 0

    ; Etiquetas individuales de controles para la sección inferior
    str_sep_top:   dw __utf16__(`\r\n----------------------------------------------------\r\n`), 0
    str_ctrl_hdr:  dw __utf16__(` CONTROLES DISPONIBLES:\r\n`), 0
    str_btn_m:     dw __utf16__(`   [M] Cambiar Modo (Reloj / Cronometro / Alarma)\r\n`), 0
    str_btn_c:     dw __utf16__(`   [C] Iniciar / Pausar Cronometro\r\n`), 0
    str_btn_r:     dw __utf16__(`   [R] Reiniciar / Resetear Cronometro\r\n`), 0
    str_btn_a:     dw __utf16__(`   [A] Configurar / Fijar Hora de Alarma\r\n`), 0
    str_btn_x:     dw __utf16__(`   [X] Desactivar / Cancelar Alarma\r\n`), 0
    str_btn_esc:   dw __utf16__(`   [ESC] Salir del Sistema UEFI\r\n`), 0
    str_sep_bot:   dw __utf16__(`----------------------------------------------------\r\n`), 0

section .text

; Inicializa los servicios de pantalla e inhabilita la visibilidad del cursor.
Screen_Init:
    sub rsp, 40
    mov r12, rdx                ; Guarda el puntero de la UEFI System Table.
    mov rax, [r12 + 64]         ; Obtiene la interfaz Simple Text Output (ConOut).
    mov rcx, rax
    xor rdx, rdx                ; Parámetro 0 para ocultar el cursor.
    mov r8, [rax + 56]          ; Puntero a la función EnableCursor.
    call r8
    add rsp, 40
    ret

; Limpia todo el contenido del terminal visual.
Screen_Clear:
    sub rsp, 40
    mov rax, [r12 + 64]         ; Obtiene la interfaz ConOut.
    mov rcx, rax
    mov r8, [rax + 48]          ; Puntero a la función ClearScreen.
    call r8
    add rsp, 40
    ret

; Cambia el color del texto utilizando los atributos de UEFI.
Screen_SetColor:
    sub rsp, 40
    mov rax, [r12 + 64]         ; Obtiene la interfaz ConOut.
    mov rcx, rax
    mov r8, [rax + 40]          ; Puntero a la función SetAttribute.
    call r8
    add rsp, 40
    ret

; Despliega la pantalla inicial de bienvenida al bootear.
Screen_DrawWelcome:
    sub rsp, 40
    
    ; Establece el color cian para la identificación institucional.
    mov rdx, 0x0B
    call Screen_SetColor

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_welcome1]
    mov r8, [rax + 8]           ; Puntero a la función OutputString.
    call r8

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_welcome2]
    mov r8, [rax + 8]
    call r8

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_welcome3]
    mov r8, [rax + 8]
    call r8

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_welcome4]
    mov r8, [rax + 8]
    call r8

    ; Establece el color amarillo para la instrucción de inicio.
    mov rdx, 0x0E
    call Screen_SetColor

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_welcome5]
    mov r8, [rax + 8]
    call r8

    ; Restaura el color gris predeterminado.
    mov rdx, 0x07
    call Screen_SetColor
    add rsp, 40
    ret

; Dibuja la sección superior de la pantalla con el título y el modo actual.
Screen_DrawHeader:
    sub rsp, 40

    ; Establece el color cian para el marco y título de la aplicación.
    mov rdx, 0x0B
    call Screen_SetColor

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_marco]
    mov r8, [rax + 8]
    call r8

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_titulo]
    mov r8, [rax + 8]
    call r8

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_marco]
    mov r8, [rax + 8]
    call r8

    ; Establece el color verde para mostrar el modo activo.
    mov rdx, 0x0A
    call Screen_SetColor

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_lbl_modo]
    mov r8, [rax + 8]
    call r8

    add rsp, 40
    ret

; Dibuja la sección inferior imprimiendo las opciones de control desde .data.
Screen_DrawFooter:
    sub rsp, 40

    ; Establece el color cian para el encabezado y separador del menú.
    mov rdx, 0x0B
    call Screen_SetColor

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_sep_top]
    mov r8, [rax + 8]
    call r8

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_ctrl_hdr]
    mov r8, [rax + 8]
    call r8

    ; Establece el color gris para el texto descriptivo de las teclas.
    mov rdx, 0x07
    call Screen_SetColor

    ; Impresión secuencial de cada instrucción de tecla.
    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_btn_m]
    mov r8, [rax + 8]
    call r8

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_btn_c]
    mov r8, [rax + 8]
    call r8

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_btn_r]
    mov r8, [rax + 8]
    call r8

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_btn_a]
    mov r8, [rax + 8]
    call r8

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_btn_x]
    mov r8, [rax + 8]
    call r8

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_btn_esc]
    mov r8, [rax + 8]
    call r8

    ; Imprime la línea separadora inferior
    mov rdx, 0x0B
    call Screen_SetColor

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_sep_bot]
    mov r8, [rax + 8]
    call r8

    mov rdx, 0x07
    call Screen_SetColor
    add rsp, 40
    ret