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
BOOT_BIN = $(BIN_DIR)/boot.bin
APP_BIN  = $(BIN_DIR)/app.bin
IMAGE    = $(BIN_DIR)/test.img


# Compilar to 
all:
	@mkdir -p $(BIN_DIR)
	$(ASM) -f bin -I $(SRC_DIR)/ $(SRC_DIR)/main.asm -o $(BOOT_BIN)
	$(ASM) -f bin -I $(SRC_DIR)/ $(SRC_DIR)/app.asm -o $(APP_BIN)

	dd if=/dev/zero of=$(IMAGE) bs=512 count=2880 status=none
	dd if=$(BOOT_BIN) of=$(IMAGE) conv=notrunc status=none
	dd if=$(APP_BIN) of=$(IMAGE) bs=512 seek=1 conv=notrunc status=none

	@echo "Compilacion terminada"

# Ejecutar en QEMU
run: all
	$(EMU) -drive file=$(IMAGE),format=raw,if=floppy -rtc base=localtime

# Borrar la bosorola
clean:
	rm -rf $(BIN_DIR)
	@echo "Archivos eliminados"