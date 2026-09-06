#include "rtc.h"


// Función para obtener el tiempo actual del sistema
EFI_STATUS RTC_ObtenerTiempo(EFI_SYSTEM_TABLE *SystemTable, RTC_Tiempo *Tiempo) {
    EFI_TIME EfiTime; // Estructura para almacenar el tiempo obtenido de UEFI
    EFI_STATUS Status; // Variable para almacenar el estado de la operación

    // Consulta de tiempo a los Runtime Services de UEFI
    Status = uefi_call_wrapper(SystemTable->RuntimeServices->GetTime, 2, &EfiTime, NULL);


    // Si la consulta fue exitosa, se copian los valores a la estructura RTC_Tiempo
    if (Status == EFI_SUCCESS) {
        Tiempo->Horas    = EfiTime.Hour;
        Tiempo->Minutos  = EfiTime.Minute;
        Tiempo->Segundos = EfiTime.Second;
        Tiempo->Dia      = EfiTime.Day;
        Tiempo->Mes      = EfiTime.Month;
        Tiempo->Anio     = EfiTime.Year;
    }

    return Status; // Retorna el estado de la operación, ya sea éxito o error
}

// Función para formatear la hora en un buffer de caracteres
void RTC_FormatearHora(RTC_Tiempo *Tiempo, CHAR16 *Buffer) {
    // Genera formato de hora "HH:MM:SS"
    SPrint(Buffer, 0, L"%02d:%02d:%02d", Tiempo->Horas, Tiempo->Minutos, Tiempo->Segundos);
}

// Función para formatear la fecha en un buffer de caracteres
void RTC_FormatearFecha(RTC_Tiempo *Tiempo, CHAR16 *Buffer) {
    // Genera formato de fecha "DD/MM/AAAA"
    SPrint(Buffer, 0, L"%02d/%02d/%04d", Tiempo->Dia, Tiempo->Mes, Tiempo->Anio);
}