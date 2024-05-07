CC = gcc
ASM = as
LD = ld
ASFLAGS = --32
LDFLAGS = -m elf_i386
LDLIBS = -nostdlib
CFLAGS = -m32 -c -std=gnu99 -ffreestanding -O2 -Wall -Wextra -Werror

TARGET = myos
BIN_TARGET = $(TARGET).bin
ISO_TARGET = $(TARGET).iso
DIR_TARGET = target
BOOT_TARGET = $(DIR_TARGET)/boot
GRUB_TARGET = $(BOOT_TARGET)/grub

all: $(BIN_TARGET) $(GRUB_TARGET)/grub.cfg
	grub-file --is-x86-multiboot $(BOOT_TARGET)/$(BIN_TARGET)
	grub-mkrescue -o $(DIR_TARGET)/$(ISO_TARGET) $(DIR_TARGET)

run: all
	qemu-system-x86_64 -cdrom $(DIR_TARGET)/$(ISO_TARGET)

boot.o:

kernel.o:

$(GRUB_TARGET)/grub.cfg: $(GRUB_TARGET)
	echo "menuentry \"$(TARGET)\" {" > $(GRUB_TARGET)/grub.cfg
	echo "	multiboot /boot/$(BIN_TARGET)" >> $(GRUB_TARGET)/grub.cfg
	echo "}" >> $(GRUB_TARGET)/grub.cfg

$(BIN_TARGET): kernel.o boot.o linker.ld $(BOOT_TARGET)
	$(LD) $(LDFLAGS) -T linker.ld kernel.o boot.o -o $(BOOT_TARGET)/$@ $(LDLIBS)

$(GRUB_TARGET):
	mkdir -p $@

$(BOOT_TARGET):
	mkdir -p $@

clean:
	$(RM) -r *.o $(DIR_TARGET)
