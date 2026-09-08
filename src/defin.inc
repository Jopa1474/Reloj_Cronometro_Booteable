; defin.inc - Estructura de Memoria y Variables Compartidas

; Variables de Tiempo Real (RTC)
reloj_horas db 0
reloj_mins db 0
reloj_segs db 0

; Variables del Cronometro
cron_horas db 0
cron_mins db 0
cron_segs db 0
cron_estado db 0
cron_ultimo_seg db 0

; Variables de la alarma
alarm_hora db 0
alarm_min db 0
alarm_on db 0
alarm_trigg db 0

alarm_d1 db 0
alarm_d2 db 0
alarm_d3 db 0
alarm_d4 db 0

; Control de modo y estado del Sistema
modo_actual db 0
tecla_presionada db 0 ; Ultimo codigo ASCII de tecla presionada 

