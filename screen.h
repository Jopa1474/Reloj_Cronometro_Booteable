#ifndef SCREEN_H
#define SCREEN_H

#include <efi.h>
#include <efilib.h>

// Atributos de color UEFI
#define COLOR_DEFAULT   (EFI_TEXT_ATTR(EFI_LIGHTGRAY, EFI_BLACK))
#define COLOR_MARCO     (EFI_TEXT_ATTR(EFI_CYAN, EFI_BLACK))
#define COLOR_TITULO    (EFI_TEXT_ATTR(EFI_YELLOW, EFI_BLACK))
#define COLOR_ALARMA    (EFI_TEXT_ATTR(EFI_LIGHTRED, EFI_BLACK))

// Declaración de funciones
void Screen_Init(EFI_SYSTEM_TABLE *SystemTable);
void Screen_Clear(EFI_SYSTEM_TABLE *SystemTable);
void Screen_SetColor(EFI_SYSTEM_TABLE *SystemTable, UINTN Atributo);
void Screen_DrawTitle(EFI_SYSTEM_TABLE *SystemTable);
void Screen_DrawControls(EFI_SYSTEM_TABLE *SystemTable);

#endif