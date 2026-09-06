# Variables de compilación
CC      = gcc
LD      = ld
OBJCOPY = objcopy

# Directorios de encabezados de GNU-EFI
EFIINC = /usr/include/efi
EFIINCS = -I$(EFIINC) -I$(EFIINC)/x86_64

# Banderas de compilación para UEFI 64-bit
CFLAGS  = $(EFIINCS) -fno-stack-protector -fpic -fshort-wchar -mno-red-zone -Wall
LDFLAGS = -shared -Bsymbolic -L/usr/lib -T /usr/lib/elf_x86_64_efi.lds /usr/lib/crt0-efi-x86_64.o

# Lista de módulos del proyecto (aquí iremos agregando los nuevos .o poco a poco)
OBJS = screen.o teclado.o rtc.o main.o
TARGET = BOOTX64.EFI

# Dispositivo USB y punto de montaje
USB_DEV = /dev/sdb1
USB_PATH = /mnt/usb

all: $(TARGET)

# Regla para compilar archivos .c a .o
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

# Regla para enlazar los objetos
main.so: $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@ -lgnuefi -lefi

# Generación del archivo ejecutable EFI
$(TARGET): main.so
	$(OBJCOPY) -j .text -j .sdata -j .data -j .dynamic -j .dynsym -j .rel -j .rela -j .reloc --target=efi-app-x86_64 $< $@

# Regla para copiar directamente a la USB limpia
install: $(TARGET)
	@echo "Montando USB e instalando $(TARGET)..."
	sudo mount $(USB_DEV) $(USB_PATH)
	sudo mkdir -p $(USB_PATH)/EFI/BOOT
	sudo cp $(TARGET) $(USB_PATH)/EFI/BOOT/BOOTX64.EFI
	sudo umount $(USB_PATH)
	sync
	@echo "Instalación completada con éxito"

# Regla para limpiar archivos generados
clean:
	rm -f *.o *.so $(TARGET)

.PHONY: all install clean