#include <efi.h>
#include <efilib.h>
#include "screen.h"
#include "teclado.h"

// Función principal de la aplicación UEFI

EFI_STATUS EFIAPI efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable) {
    InitializeLib(ImageHandle, SystemTable); // Inicializa la biblioteca UEFI

    // Inicializa la pantalla y dibuja el título y los controles
    Screen_Init(SystemTable);
    Screen_DrawTitle(SystemTable);
    
    // Muestra el modo y la hora inicial
    Screen_SetColor(SystemTable, COLOR_TITULO);
    Print(L"Modo: RELOJ\n");
    Print(L"Hora: 00:00:00\n");

    // Dibuja los controles en la pantalla
    Screen_DrawControls(SystemTable);

    // Bucle principal para leer las acciones del teclado
    while (TRUE) {
        ACCION_TECLA accion = Teclado_LeerAccion(SystemTable);

        if (accion == ACCION_SALIR) {
            Print(L"\nSaliendo...\n");
            break;
        }

        if (accion == ACCION_CAMBIAR_MODO)  Print(L"\n-> Accion: [M] Cambiar modo");
        if (accion == ACCION_CRONO_TOGGLE)  Print(L"\n-> Accion: [C] Iniciar/Pausar cronometro");
        if (accion == ACCION_CRONO_RESET)   Print(L"\n-> Accion: [R] Reiniciar cronometro");
        if (accion == ACCION_SET_ALARMA)    Print(L"\n-> Accion: [A] Configurar alarma");
        if (accion == ACCION_CANCEL_ALARMA) Print(L"\n-> Accion: [X] Cancelar alarma");

        // Pequeña pausa de 50ms para no saturar el CPU
        uefi_call_wrapper(SystemTable->BootServices->Stall, 1, 50000);
    }

    return EFI_SUCCESS;
}