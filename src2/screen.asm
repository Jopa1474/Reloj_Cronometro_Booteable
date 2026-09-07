; MÓDULO: screen.asm
; ENTORNO: UEFI x86-64 Nativo
; DESCRIPCIÓN: Administra la salida de consola (ConOut) usando servicios UEFI.

bits 64                         ; Modo x86-64 bits
default rel                     ; Inserción de direccionamiento relativo al RIP (código posicionable)

; Exportar etiquetas para que otros archivos (.asm) puedan llamarlas
global Screen_Init
global Screen_Clear
global Screen_SetColor
global Screen_DrawWelcome
global Screen_DrawTitle
global Screen_DrawControls


; Sección de datos constantes (.data)
; UEFI requiere cadenas codificadas en UTF-16 (UCS-2 de 16 bits por carácter).
; Cada línea termina en retorno de carro (\r), salto de línea (\n) y cero de cierre (0).

section .data
    str_welcome1: dw __utf16__(`====================================================\r\n`), 0
    str_welcome2: dw __utf16__(`   INSTITUTO TECNOLOGICO DE COSTA RICA - CE4303    \r\n`), 0
    str_welcome3: dw __utf16__(`     TAREA 1: RELOJ / CRONOMETRO BOOTEABLE UEFI     \r\n`), 0
    str_welcome4: dw __utf16__(`====================================================\r\n\r\n`), 0
    str_welcome5: dw __utf16__(`Presione [ENTER] o cualquier tecla para iniciar...\r\n`), 0

    str_marco:   dw __utf16__(`====================================================\r\n`), 0
    str_titulo:  dw __utf16__(`             RELOJ / CRONOMETRO CON ALARMA          \r\n`), 0
    str_ctrls:   dw __utf16__(`\r\n----------------------------------------------------\r\n`), 0
                 dw __utf16__(`[M] Cambiar Modo | [C] Start/Pause Crono | [R] Reset\r\n`), 0
                 dw __utf16__(`[A] Fijar Alarma | [X] Cancelar Alarma   | [ESC] Salir\r\n`), 0
                 dw __utf16__(`----------------------------------------------------\r\n`), 0


; Sección de código (.text)
; Contiene las instrucciones que la CPU ejecuta directamente.

section .text


; Función: Screen_Init
; Descripción: Configura el entorno de consola UEFI inicial (desactiva cursor).
; Entrada:  RDX = Puntero a la tabla UEFI SystemTable

Screen_Init:
    sub rsp, 40 ; Reservar 32 bytes (Shadow Space) + 8 bytes (alineación)
    mov r12, rdx ; Guardar SystemTable en R12 (R12 no es destruido por llamadas)

    ; Estructura UEFI: SystemTable -> ConOut (offset +64) -> EnableCursor (offset +56)
    mov rax, [r12 + 64]         ; RAX = Dirección de ConOut
    mov rcx, rax                ; Parámetro 1 (RCX): Puntero al objeto ConOut
    xor rdx, rdx                ; Parámetro 2 (RDX): 0 (FALSE = ocultar cursor)
    mov r8, [rax + 56]          ; R8 = Dirección de la función EnableCursor
    call r8                     ; Ejecutar llamada UEFI

    add rsp, 40                 ; Liberar espacio reservado en la pila
    ret                         ; Retornar al llamador

; Función: Screen_Clear
; Descripción: Limpia todo el texto de la pantalla.
; Entrada:  R12 = Puntero guardado a SystemTable

Screen_Clear:
    sub rsp, 40
    mov rax, [r12 + 64]         ; RAX = ConOut
    mov rcx, rax                ; Parámetro 1: Puntero a ConOut
    mov r8, [rax + 48]          ; R8 = Dirección de ClearScreen (offset +48)
    call r8                     ; Ejecutar ClearScreen()
    add rsp, 40
    ret


; Función: Screen_SetColor
; Descripción: Cambia el color de fondo y primer plano del texto impreso.
; Entrada:  R12 = SystemTable, RDX = Código hexadecimal del color (ej: 0x0E = Amarillo)
Screen_SetColor:
    sub rsp, 40
    mov rax, [r12 + 64]         ; RAX = ConOut
    mov rcx, rax                ; Parámetro 1: Puntero a ConOut
                                ; Parámetro 2: RDX ya trae el color deseado
    mov r8, [rax + 40]          ; R8 = Dirección de SetAttribute (offset +40)
    call r8                     ; Ejecutar SetAttribute(ConOut, Color)
    add rsp, 40
    ret

; Función: Screen_DrawWelcome
; Descripción: Muestra la pantalla inicial con información de la asignatura/instituto.
; Entrada:  R12 = SystemTable

Screen_DrawWelcome:
    sub rsp, 40

    ; Configurar texto a color Cyan Claro (0x0B)
    mov rdx, 0x0B               
    call Screen_SetColor

    ; Paso 2: Imprimir cada línea usando ConOut->OutputString (offset +8)
    mov rax, [r12 + 64]         ; RAX = ConOut
    mov rcx, rax                ; Parámetro 1: ConOut
    lea rdx, [str_welcome1]     ; Parámetro 2: Dirección de la cadena UTF-16
    mov r8, [rax + 8]           ; R8 = Función OutputString
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

    ; Paso 3: Cambiar a Amarillo (0x0E) para la instrucción interactiva
    mov rdx, 0x0E
    call Screen_SetColor

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_welcome5]
    mov r8, [rax + 8]
    call r8

    ; Paso 4: Restaurar color estándar blanco/gris (0x07)
    mov rdx, 0x07
    call Screen_SetColor

    add rsp, 40
    ret

; Función: Screen_DrawTitle
; Descripción: Dibuja el marco superior del aplicativo principal.
; Entrada:  R12 = SystemTable

Screen_DrawTitle:
    sub rsp, 40
    mov rdx, 0x0B               ; Cyan
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

    mov rdx, 0x07               ; Restaurar color base
    call Screen_SetColor
    add rsp, 40
    ret

; Función: Screen_DrawControls
; Descripción: Dibuja la barra de comandos e instrucciones en la parte inferior.
; Entrada:  R12 = SystemTable

Screen_DrawControls:
    sub rsp, 40
    mov rdx, 0x0B               ; Cyan
    call Screen_SetColor

    mov rax, [r12 + 64]
    mov rcx, rax
    lea rdx, [str_ctrls]
    mov r8, [rax + 8]
    call r8

    mov rdx, 0x07               ; Restaurar color base
    call Screen_SetColor
    add rsp, 40
    ret