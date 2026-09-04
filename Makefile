# Makefile - Tarea 1 de Sistemas Operativos

# Compilador y emulador

ASM = nasm# Compilador de ensamblador
EMU = qemu-system-x86_64# Emulador para arquitectura x86_64

# Flags para el compilador de ensamblador
ASMFLAGS = -f bin# Flags para el compilador de ensamblador

# Directorios de la tarea
SRC_DIR = src# Directorio de código fuente
BIN_DIR = bin# Directorio de archivos binarios

# Archivos fuente y binarios
TARGET_SRC = $(SRC_DIR)/main.asm# Archivo fuente principal
TARGET_BIN = $(BIN_DIR)/boot.bin# Archivo binario principal

# Regla por defecto
.PHONY: all build run clean

all: build run

# Regla de Compilacion
# Crea la carpeta bin si no existe y ensambla el codigo 

build:
	@mkdir -p $(BIN_DIR)
	$(ASM) $(ASMFLAGS) $(TARGET_SRC) -o $(TARGET_BIN)
	@echo "Compilación completada. Archivo binario generado en $(TARGET_BIN)"

# Regla de Ejecucion
# Ejecuta el archivo binario generado en QEMU
run:
	$(EMU) -fda $(TARGET_BIN)


# Regla de Limpieza
# Elimina los archivos binarios generados
clean:#
	@rm -rf $(BIN_DIR)
	@echo "Archivos binarios eliminados."
