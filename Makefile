# ==============================================================================
# CONFIGURACIÓN DE DISPOSITIVO USB
# Ajusta estas variables según tu sistema (p. ej. /dev/sdc1, /dev/sdb1)
# ==============================================================================
USB_DEV  ?= /dev/sdb1
USB_PATH ?= /mnt/usb

# Herramientas de compilación
CC      = gcc
LD      = ld
OBJCOPY = objcopy

# Directorios de encabezados UEFI
EFIINC  = /usr/include/efi
EFIINCS = -I$(EFIINC) -I$(EFIINC)/x86_64

# Banderas de compilación
CFLAGS  = $(EFIINCS) -fno-stack-protector -fpic -fshort-wchar -mno-red-zone -Wall
LDFLAGS = -shared -Bsymbolic -L/usr/lib -T /usr/lib/elf_x86_64_efi.lds /usr/lib/crt0-efi-x86_64.o

# Objetos del proyecto (Módulos 1, 2 y 3)
OBJS   = screen.o teclado.o rtc.o main.o
TARGET = BOOTX64.EFI

all: $(TARGET)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

main.so: $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@ -lgnuefi -lefi

$(TARGET): main.so
	$(OBJCOPY) -j .text -j .sdata -j .data -j .dynamic -j .dynsym -j .rel -j .rela -j .reloc --target=efi-app-x86_64 $< $@

# Regla de instalación en la USB
install: $(TARGET)
	@echo "Montando USB ($(USB_DEV)) en $(USB_PATH)..."
	sudo mount $(USB_DEV) $(USB_PATH)
	sudo mkdir -p $(USB_PATH)/EFI/BOOT
	sudo cp $(TARGET) $(USB_PATH)/EFI/BOOT/BOOTX64.EFI
	sudo umount $(USB_PATH)
	sync
	@echo "¡Copia completada con exito en $(USB_DEV)!"

clean:
	rm -f *.o *.so $(TARGET)

.PHONY: all install clean