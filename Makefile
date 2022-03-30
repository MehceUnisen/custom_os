CC := gcc
CC_FLAGS := -g -fno-pie -ffreestanding -c -w

LINK := ld
LDS := linker.ld
LINK_FLAGS := -T $(LDS) -static -Bsymbolic -nostdlib

NASM_FLAGS := -f elf64

KERNEL_DIR := src/kernel
BOOTLOADER_DIR := src/bootloader
DRIVER_DIR := drivers
BUILD_DIR := build
OBJ_DIR := build/obj

C_SRC_FILES = $(wildcard src/kernel/*.c drivers/*.c)
C_HEADER_FILES = $(wildcard src/kernel/header/*.h driver/header/*.h)
OBJ_FILES = ${C_SRC_FILES:.c=.o}


bootloader.bin: $(BOOTLOADER_DIR)/bootloader.asm
	nasm $< -f bin -o bootloader.bin -i 'src/bootloader'

call_kernel.bin: call_kernel.o ${OBJ_FILES}
	$(LINK) $(LINK_FLAGS) -Ttext 0x1000 -o $@  $^ --oformat binary

call_kernel.o: $(BOOTLOADER_DIR)/call_kernel.asm
	nasm $(NASM_FLAGS) -o $@ $< -i 'src/bootloader'

%.o: %.c
	${CC} ${CCFLAGS} -ffreestanding -c $< -o $@

bootloader.bin: $(BOOTLOADER_DIR)/bootloader.asm
	nasm $< -f bin -o bootloader.bin -i 'src/bootloader'

run:
	qemu-system-x86_64 bootloader.bin

clean:
	rm *.ini *.o *.bin ${OBJ_FILES}

boot: bootloader.bin
	qemu-system-x86_64 bootloader.bin