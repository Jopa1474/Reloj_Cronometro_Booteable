#include <efi.h>
#include <efilib.h>
#include "screen.h"
#include "teclado.h"
#include "rtc.h"

EFI_STATUS EFIAPI efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable) {
    InitializeLib(ImageHandle, SystemTable);

    RTC_Tiempo tiempo;
    CHAR16 strHora[16];
    CHAR16 strFecha[16];

    Screen_Init(SystemTable);

    while (TRUE) {
        // Limpiar y dibujar interfaz estática
        Screen_Clear(SystemTable);
        Screen_DrawTitle(SystemTable);

        // Obtener lectura actual del RTC
        if (RTC_ObtenerTiempo(SystemTable, &tiempo) == EFI_SUCCESS) {
            RTC_FormatearHora(&tiempo, strHora);
            RTC_FormatearFecha(&tiempo, strFecha);

            Screen_SetColor(SystemTable, COLOR_TITULO);
            Print(L"Modo: RELOJ (RTC)\n\n");
            Print(L"Hora: %s\n", strHora);
            Print(L"Fecha: %s\n", strFecha);
        }

        Screen_DrawControls(SystemTable);

        // Revisar si se presionó la tecla ESC para salir
        ACCION_TECLA accion = Teclado_LeerAccion(SystemTable);
        if (accion == ACCION_SALIR) {
            break;
        }

        // Pausa de 200ms entre refrescos
        uefi_call_wrapper(SystemTable->BootServices->Stall, 1, 200000);
    }

    Screen_Clear(SystemTable);
    Print(L"Programa finalizado.\n");

    return EFI_SUCCESS;
}