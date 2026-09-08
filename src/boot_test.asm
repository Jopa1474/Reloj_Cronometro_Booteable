; ============================================================
; boot_test.asm
; Mini bootloader SOLO para probar la aplicación en QEMU
;
; Carga 16 sectores desde el disco a 0x1000:0000
; y luego salta a esa dirección.
; ============================================================

bits 16
org 0x7C00

start:
    ; BIOS nos deja el número del disco de arranque en DL
    mov [boot_drive], dl

    ; --------------------------------------------------------
    ; Configurar segmentos
    ; --------------------------------------------------------
    cli

    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax

    mov sp, 0x7C00

    sti

    ; --------------------------------------------------------
    ; Mostrar mensaje
    ; --------------------------------------------------------
    mov si, msg_boot
    call print_string

    ; --------------------------------------------------------
    ; Cargar nuestra aplicación en:
    ;
    ; 0x1000:0000
    ;
    ; Dirección física = 0x10000
    ; --------------------------------------------------------

    mov ax, 0x1000
    mov es, ax

    xor bx, bx          ; ES:BX = 1000:0000

    ; INT 13h / AH=02h
    ; Leer sectores desde disco

    mov ah, 0x02        ; función: leer sectores
    mov al, 16          ; leer 16 sectores = máximo 8192 bytes

    mov ch, 0           ; cilindro 0
    mov cl, 2           ; empezar en sector 2
                        ; sector 1 contiene el bootloader

    mov dh, 0           ; cabeza 0

    mov dl, [boot_drive]

    int 0x13

    jc disk_error       ; Carry Flag = error

    ; --------------------------------------------------------
    ; Aplicación cargada correctamente
    ; --------------------------------------------------------

    mov si, msg_ok
    call print_string

    ; Saltar a la aplicación

    jmp 0x1000:0x0000


; ============================================================
; Error leyendo disco
; ============================================================

disk_error:

    mov si, msg_error
    call print_string

hang:
    cli
    hlt
    jmp hang


; ============================================================
; print_string
;
; DS:SI = string terminado en 0
; ============================================================

print_string:

.next:

    lodsb

    cmp al, 0
    je .done

    mov ah, 0x0E
    mov bh, 0x00
    int 0x10

    jmp .next

.done:
    ret


; ============================================================
; Datos
; ============================================================

boot_drive db 0

msg_boot db 13,10
         db 'Mini boot iniciado...',13,10
         db 'Cargando app.bin...',13,10,0

msg_ok db 'Aplicacion cargada.',13,10,0

msg_error db 'ERROR: no se pudo cargar app.bin.',13,10,0


; ============================================================
; Rellenar hasta 510 bytes
; ============================================================

times 510 - ($ - $$) db 0


; Firma de boot
dw 0xAA55