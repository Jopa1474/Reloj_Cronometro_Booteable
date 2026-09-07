
; Módulo: rtc.asm
; Descripción: Acceso al chip RTC mediante RuntimeServices->GetTime y
;              conversión a la zona horaria local de Costa Rica (UTC-6).


bits 64                         ; Habilitar modo de 64 bits
default rel                     ; Posicionamiento relativo al RIP (código ejecutable portable)

global RTC_GetTime              ; Exportar función para su uso en main.asm

section .text


; Función: RTC_GetTime
; Descripción: Consulta la hora actual del chip RTC y aplica compensación UTC-6.
; Entrada:  R12 = Puntero persistente a UEFI SystemTable
; Salida:   CH  = Horas en formato 24h (0 - 23)
;           CL  = Minutos (0 - 59)
;           DH  = Segundos (0 - 59)

RTC_GetTime:
    sub rsp, 56                 ; Reservar 32 bytes (Shadow Space) + 16 bytes (Estructura EFI_TIME) + 8 bytes (Alineación)

    ; Acceder al servicio de tiempo de UEFI
    mov rax, [r12 + 88]         ; RAX = SystemTable->RuntimeServices (Offset +88)
    lea rcx, [rsp + 32]         ; Parámetro 1 (RCX): Puntero al buffer temporal de 16 bytes para EFI_TIME
    xor rdx, rdx                ; Parámetro 2 (RDX): NULL (no se requieren capacidades adicionales)
    mov r8, [rax + 24]          ; R8 = Dirección de la función GetTime (Offset +24)
    call r8                     ; Invocación a GetTime(&EFI_TIME, NULL)

    ; Verificar si la llamada fue exitosa
    test rax, rax               ; ¿RAX == 0 (EFI_SUCCESS)?
    jnz .error                  ; Si hubo error, saltar a inicialización limpia (00:00:00)

    ; Extraer componentes de tiempo desde la estructura EFI_TIME
    ; Offsets internos de EFI_TIME:
    ; +0: Year (UINT16), +2: Month (UINT8), +3: Day (UINT8)
    ; +4: Hour (UINT8),  +5: Minute (UINT8), +6: Second (UINT8)
    mov ch, byte [rsp + 36]     ; CH = Hour (Offset +4)
    mov cl, byte [rsp + 37]     ; CL = Minute (Offset +5)
    mov dh, byte [rsp + 38]     ; DH = Second (Offset +6)

    ; Ajuste de Zona Horaria (UTC-6 para Costa Rica)
    sub ch, 6                   ; Restar 6 horas a la hora UTC reportada por el firmware
    jns .done                   ; Si el resultado no es negativo, terminar
    add ch, 24                  ; Si dio negativo (ej. 02:00 - 6 = -4), sumar 24h para ajustar al día anterior (20:00)

    jmp .done

.error:
    xor cx, cx                  ; En caso de fallo, colocar CH=0, CL=0
    xor dh, dh                  ; Colocar DH=0

.done:
    add rsp, 56                 ; Liberar el espacio reservado en la pila
    ret                         ; Retornar al hilo de ejecución principal