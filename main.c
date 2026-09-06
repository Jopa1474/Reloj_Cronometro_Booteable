#include <efi.h>
#include <efilib.h>
#include "screen.h"

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

    // Pausa para verificar la pantalla
    UINTN Index;
    EFI_INPUT_KEY Key;
    uefi_call_wrapper(SystemTable->BootServices->WaitForEvent, 3, 1, &SystemTable->ConIn->WaitForKey, &Index);
    uefi_call_wrapper(SystemTable->ConIn->ReadKeyStroke, 2, SystemTable->ConIn, &Key);

    return EFI_SUCCESS;
}