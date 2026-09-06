#ifndef TECLADO_H
#define TECLADO_H

#include <efi.h>
#include <efilib.h>

// Definición de acciones reconocidas
typedef enum {
    ACCION_NINGUNA,
    ACCION_CAMBIAR_MODO,     // Tecla M
    ACCION_CRONO_TOGGLE,     // Tecla C
    ACCION_CRONO_RESET,      // Tecla R
    ACCION_SET_ALARMA,       // Tecla A
    ACCION_CANCEL_ALARMA,    // Tecla X
    ACCION_SALIR             // Tecla ESC
} ACCION_TECLA;

// Funciones del módulo de teclado
ACCION_TECLA Teclado_LeerAccion(EFI_SYSTEM_TABLE *SystemTable);

#endif