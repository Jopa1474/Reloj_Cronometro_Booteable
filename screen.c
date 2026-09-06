#include "screen.h"

// Función para inicializar la pantalla y ocultar el cursor
void Screen_Init(EFI_SYSTEM_TABLE *SystemTable) {
    uefi_call_wrapper(SystemTable->ConOut->EnableCursor, 2, SystemTable->ConOut, FALSE);
    Screen_Clear(SystemTable);
}

// Función para limpiar la pantalla y establecer el color por defecto
void Screen_Clear(EFI_SYSTEM_TABLE *SystemTable) {
    Screen_SetColor(SystemTable, COLOR_DEFAULT); 
    uefi_call_wrapper(SystemTable->ConOut->ClearScreen, 2, SystemTable->ConOut);
}

// Función para establecer el color de la pantalla
void Screen_SetColor(EFI_SYSTEM_TABLE *SystemTable, UINTN Atributo) {
    uefi_call_wrapper(SystemTable->ConOut->SetAttribute, 2, SystemTable->ConOut, Atributo); 
}

// Función para dibujar el título del programa en la pantalla
void Screen_DrawTitle(EFI_SYSTEM_TABLE *SystemTable) {
    Screen_SetColor(SystemTable, COLOR_MARCO);
    Print(L"========================================\n");
    Print(L"        RELOJ / CRONOMETRO              \n");
    Print(L"========================================\n\n");
    Screen_SetColor(SystemTable, COLOR_DEFAULT);
}

// Función para dibujar los controles disponibles en la pantalla
void Screen_DrawControls(EFI_SYSTEM_TABLE *SystemTable) {
    Screen_SetColor(SystemTable, COLOR_MARCO);
    Print(L"\n[M] Cambiar modo\n");
    Print(L"[C] Iniciar/Pausar cronometro\n");
    Print(L"[R] Reiniciar cronometro\n");
    Print(L"[A] Configurar alarma\n");
    Print(L"[X] Cancelar alarma\n");
    Screen_SetColor(SystemTable, COLOR_DEFAULT);
}