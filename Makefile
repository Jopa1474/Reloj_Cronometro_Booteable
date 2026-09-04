BUILD = build
SRC = src

IMAGE = $(BUILD)/test.img
BOOT = $(BUILD)/boot_test.bin
APP = $(BUILD)/app.bin


all: $(IMAGE)


$(BUILD):
	mkdir -p $(BUILD)


$(BOOT): $(SRC)/boot_test.asm | $(BUILD)
	nasm -f bin $(SRC)/boot_test.asm -o $(BOOT)


$(APP): $(SRC)/app.asm | $(BUILD)
	nasm -f bin -I $(SRC)/ $(SRC)/app.asm -o $(APP)


$(IMAGE): $(BOOT) $(APP)
	dd if=/dev/zero of=$(IMAGE) bs=512 count=2880
	dd if=$(BOOT) of=$(IMAGE) conv=notrunc
	dd if=$(APP) of=$(IMAGE) bs=512 seek=1 conv=notrunc


run: $(IMAGE)
	qemu-system-i386 \
		-drive file=$(IMAGE),format=raw,if=floppy \
		-rtc base=localtime


clean:
	rm -rf $(BUILD)


.PHONY: all run clean