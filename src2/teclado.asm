; Módulo: teclado.asm
; Entorno: UEFI x86-64 Nativo
; Descripción: Manejo de entrada por teclado usando ConIn->ReadKeyStroke.


bits 64
default rel

global Teclado_ReadChar

section .text


; Función: Teclado_ReadChar
; Descripción: Lee una tecla del buffer de entrada sin bloquear el programa.
; Entrada:  R12 = SystemTable
; Salida:   RAX = Carácter Unicode/ASCII de la tecla (o 0 si no hay tecla o es tecla especial)
;           RDX = ScanCode de la tecla especial (ej: 0x17 para ESC)

Teclado_ReadChar:
    sub rsp, 40                 ; Reservar Shadow Space (32) + Alineación (8)

    ; Reservar espacio en la pila para la estructura EFI_INPUT_KEY (4 bytes)
    ; rsp + 32 -> Estructura EFI_INPUT_KEY:
    ;   [rsp + 32]: ScanCode (WORD - 2 bytes)
    ;   [rsp + 34]: UnicodeChar (WORD - 2 bytes)

    mov rax, [r12 + 48]         ; RAX = SystemTable->ConIn
    mov rcx, rax                ; Parámetro 1 (RCX): ConOut / ConIn objeto
    lea rdx, [rsp + 32]         ; Parámetro 2 (RDX): Puntero a EFI_INPUT_KEY en la pila
    mov r8, [rax + 8]           ; R8 = Dirección de ReadKeyStroke
    call r8                     ; Invocación a ReadKeyStroke(ConIn, &KeyData)

    ; Comprobar el código de retorno de la función UEFI
    test rax, rax               ; ¿RAX == 0 (EFI_SUCCESS)?
    jnz .no_key                 ; Si no es 0 (ej: EFI_NOT_READY), no hay tecla presionada

    ; Extraer valores de la estructura EFI_INPUT_KEY
    movzx rdx, word [rsp + 32]  ; RDX = ScanCode
    movzx rax, word [rsp + 34]  ; RAX = UnicodeChar
    jmp .done

.no_key:
    xor rax, rax                ; Devolver 0 en RAX (sin carácter)
    xor rdx, rdx                ; Devolver 0 en RDX (sin ScanCode)

.done:
    add rsp, 40
    ret