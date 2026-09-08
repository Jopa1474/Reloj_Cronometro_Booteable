# Makefile - Tarea 1 de Sistemas Operativos

# Compilador y emulador
ASM = nasm
EMU = qemu-system-x86_64

# Flags para el compilador de ensamblador
ASMFLAGS = -f bin

# Directorios de la tarea
SRC_DIR = src
BIN_DIR = bin

# Archivos fuente y binarios
BOOT_BIN = $(BIN_DIR)/boot.bin
APP_BIN  = $(BIN_DIR)/app.bin
IMAGE    = $(BIN_DIR)/test.img

# Compilacion general
all:
	@mkdir -p $(BIN_DIR)
	$(ASM) $(ASMFLAGS) -I $(SRC_DIR)/ $(SRC_DIR)/main.asm -o $(BOOT_BIN)
	$(ASM) $(ASMFLAGS) -I $(SRC_DIR)/ $(SRC_DIR)/app.asm -o $(APP_BIN)

	dd if=/dev/zero of=$(IMAGE) bs=512 count=2880 status=none
	dd if=$(BOOT_BIN) of=$(IMAGE) conv=notrunc status=none
	dd if=$(APP_BIN) of=$(IMAGE) bs=512 seek=1 conv=notrunc status=none

	@echo "Compilacion terminada"

# Ejecutar en QEMU
run: all
	$(EMU) -drive file=$(IMAGE),format=raw, -rtc base=localtime

# Grabar la imagen binaria en una USB concreta
# Uso: sudo make burn DEV=/dev/sdX  (reemplazar sdX por el dispositivo USB real)
burn: all
ifndef DEV
	@echo "Error: Debe especificar el dispositivo USB usando DEV=/dev/sdX"
	@echo "Ejemplo: sudo make burn DEV=/dev/sdb"
	@exit 1
else
	@echo "Atencion: Se escribira en $(DEV). Asegurese de que sea la USB correcta."
	sudo dd if=$(IMAGE) of=$(DEV) bs=4M status=progress conv=fsync
	@echo "Grabacion en USB finalizada con exito."
endif

# Detectar y mostrar los dispositivos USB montados en el sistema
ls-usb:
	@echo "Dispositivos de almacenamiento detectados:"
	@lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep -E "disk|part"

# Limpieza de binarios creados
clean:
	rm -rf $(BIN_DIR)
	@echo "Archivos eliminados"