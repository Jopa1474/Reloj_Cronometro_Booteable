#ifndef RTC_H
#define RTC_H

#include <efi.h>
#include <efilib.h>

// Estructura simplificada para manejar el tiempo de manera limpia
typedef struct {
    UINT8 Horas;
    UINT8 Minutos;
    UINT8 Segundos;
    UINT8 Dia;
    UINT8 Mes;
    UINT16 Anio;
} RTC_Tiempo;

// Funciones expuestas del módulo RTC
EFI_STATUS RTC_ObtenerTiempo(EFI_SYSTEM_TABLE *SystemTable, RTC_Tiempo *Tiempo);
void RTC_FormatearHora(RTC_Tiempo *Tiempo, CHAR16 *Buffer);
void RTC_FormatearFecha(RTC_Tiempo *Tiempo, CHAR16 *Buffer);

#endif // RTC_H