#include "teclado.h"


// Función para leer la acción correspondiente a la tecla presionada
ACCION_TECLA Teclado_LeerAccion(EFI_SYSTEM_TABLE *SystemTable) {
    EFI_INPUT_KEY Key; // Variable para almacenar la tecla presionada
    EFI_STATUS Status; // Variable para almacenar el estado de la operación

    // Consultar si se presionó alguna tecla sin detener el programa
    Status = uefi_call_wrapper(SystemTable->ConIn->ReadKeyStroke, 2, SystemTable->ConIn, &Key);
    
    // Si no se presionó ninguna tecla, retornar ACCION_NINGUNA
    if (Status != EFI_SUCCESS) {
        return ACCION_NINGUNA;
    }

    // ScanCode 0x17 equivale a la tecla ESC
    if (Key.ScanCode == 0x17) {
        return ACCION_SALIR;
    }

    // Mapeo directo con las teclas
    switch (Key.UnicodeChar) {
        case L'm': case L'M': return ACCION_CAMBIAR_MODO;
        case L'c': case L'C': return ACCION_CRONO_TOGGLE;
        case L'r': case L'R': return ACCION_CRONO_RESET;
        case L'a': case L'A': return ACCION_SET_ALARMA;
        case L'x': case L'X': return ACCION_CANCEL_ALARMA;
        default: return ACCION_NINGUNA;
    }
}