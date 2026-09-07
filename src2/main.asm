; Módulo: main.asm
; Descripción: Flujo de inicio del programa (Punto de entrada EFI)

bits 64
default rel

global efi_main

; Declaración de funciones externas definidas en screen.asm
extern Screen_Init
extern Screen_Clear
extern Screen_SetColor
extern Screen_DrawWelcome
extern Screen_DrawTitle
extern Screen_DrawControls

section .data
    str_test: dw __utf16__(`[OK] Bienvenida superada. Presione cualquier tecla para salir...\r\n`), 0

section .text

; PUNTO DE ENTRADA PRINCIPAL
; Al arrancar, UEFI coloca en RDX la dirección de memoria de SystemTable.

efi_main:
    ; Preparar la pila reservando espacio sombra (Shadow Space)
    sub rsp, 56                 ; Reservar espacio en la pila para llamadas y alineación

    ; Preservar la referencia maestra a SystemTable
    mov r12, rdx                ; Copiamos RDX (SystemTable) a R12 para no perderlo

    ; Inicialización gráfica
    call Screen_Init            ; Configura la consola (oculta el cursor)
    call Screen_Clear           ; Limpia la pantalla dejándola en negro

    ; Dibujar la Pantalla de Bienvenida
    call Screen_DrawWelcome     ; Muestra el título del ITCR y la orden de presionar tecla

    ; Bucle de espera de tecla (Pausa de confirmación)
.esperar_confirmacion:
    lea rdx, [rsp + 32]         ; RDX = Puntero a un buffer temporal en la pila
    mov rax, [r12 + 48]         ; RAX = Puntero a SystemTable->ConIn
    mov rcx, rax                ; RCX = Puntero a ConIn (Parámetro 1)
    mov r8, [rax + 8]           ; R8 = Puntero a la función ReadKeyStroke
    call r8                     ; Llamada a ReadKeyStroke(ConIn, Buffer)

    test rax, rax               ; ¿RAX == 0 (EFI_SUCCESS)?
    jnz .esperar_confirmacion   ; Si no es 0 (no hay tecla presioanda), repetir bucle

    ; Transición a la interfaz principal
    call Screen_Clear           ; Limpiar la pantalla de bienvenida
    call Screen_DrawTitle       ; Dibujar el marco superior del reloj

    mov rdx, 0x0A               ; RDX = 0x0A (Color Verde Claro)
    call Screen_SetColor        ; Cambiar color del texto

    ; Imprimir mensaje de éxito en pantalla
    mov rax, [r12 + 64]         ; RAX = SystemTable->ConOut
    mov rcx, rax                ; RCX = ConOut (Parámetro 1)
    lea rdx, [str_test]         ; RDX = Puntero a la cadena de texto (Parámetro 2)
    mov r8, [rax + 8]           ; R8 = Función OutputString
    call r8                     ; Imprimir cadena en pantalla

    call Screen_DrawControls    ; Dibujar las instrucciones de control inferiores

    ; Esperar una tecla final antes de salir
.esperar_salida:
    lea rdx, [rsp + 32]
    mov rax, [r12 + 48]         ; ConIn
    mov rcx, rax
    mov r8, [rax + 8]           ; ReadKeyStroke
    call r8
    test rax, rax
    jnz .esperar_salida

    ; Salida limpia del programa
    call Screen_Clear           ; Dejar pantalla limpia
    xor rax, rax                ; Devolver 0 (EFI_SUCCESS)
    add rsp, 56                 ; Restaurar la pila a su estado original
    ret                         ; Devolver el control al Boot Manager de UEFI