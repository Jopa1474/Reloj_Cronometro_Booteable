ASM = nasm
LD  = x86_64-w64-mingw32-ld

#Cambiar segun la direccion del dispositivo USB y la ruta de montaje
USB_DEV  ?= /dev/sdb1
USB_PATH ?= /mnt/usb

SRC_DIR = src2
OBJS    = $(SRC_DIR)/screen.o $(SRC_DIR)/teclado.o $(SRC_DIR)/main.o
TARGET  = BOOTX64.EFI

all: $(TARGET)

$(SRC_DIR)/%.o: $(SRC_DIR)/%.asm
	$(ASM) -f win64 $< -o $@

$(TARGET): $(OBJS)
	$(LD) -subsystem 10 -e efi_main $(OBJS) -o $(TARGET)

install: $(TARGET)
	@echo "Montando USB ($(USB_DEV)) en $(USB_PATH)..."
	sudo mount $(USB_DEV) $(USB_PATH)
	sudo mkdir -p $(USB_PATH)/EFI/BOOT
	sudo cp $(TARGET) $(USB_PATH)/EFI/BOOT/BOOTX64.EFI
	sudo umount $(USB_PATH)
	sync
	@echo "¡Copia completada con exito!"

clean:
	rm -f $(SRC_DIR)/*.o $(TARGET)

.PHONY: all install clean