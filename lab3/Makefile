all: image

.PHONY=clean qemu

system:boot/head.o init/main.o kernel/printk.o kernel/getchar.o
	- @ld -T ld_sys.ld -m elf_i386 boot/head.o init/main.o kernel/printk.o kernel/getchar.o -o system.sym
	- @strip system.sym -o system.o
	- @objcopy -O binary -R .note -R .comment system.o system

boot/head.o:boot/head.s
	- @as --32 boot/head.s -o boot/head.o

boot/bootsect:boot/bootsect.s boot/ld_boot.ld
	- @as --32 boot/bootsect.s -o boot/bootsect.o
	- @ld -T boot/ld_boot.ld boot/bootsect.o -o boot/bootsect
	- @objcopy -O binary -j .text boot/bootsect

boot/setup:boot/setup.s boot/ld_boot.ld
	- @as --32 boot/setup.s -o boot/setup.o
	- @ld -T boot/ld_boot.ld boot/setup.o -o boot/setup
	- @objcopy -O binary -j .text boot/setup

init/main.o:init/main.c
	- @gcc -m32 -c init/main.c -fno-stack-protector -o init/main.o

kernel/printk.o:kernel/printk.c
	- @gcc -m32 -c kernel/printk.c -fno-stack-protector -o kernel/printk.o

kernel/getchar.o:kernel/getchar.c
	- @gcc -m32 -c kernel/getchar.c -fno-stack-protector -o kernel/getchar.o

image:boot/bootsect boot/setup system
	- @dd if=boot/bootsect of=image.img bs=512 count=1
	- @dd if=boot/setup of=image.img bs=512 count=4 seek=1
	- @dd if=system of=image.img bs=512 count=1440 seek=5
	- @dd if=/dev/zero of=image.img bs=512 count=1435 seek=1445
	- @echo "image built done"
# image of this system

clean:
	- @rm -f boot/*.o boot/bootsect boot/setup
	- @rm -f init/*.o
	- @rm -f kernel/*.o
	- @rm -f system system.o system.sym image.img

qemu:image
	- @qemu-system-i386 -boot a -fda image.img
# -fda running from virtual floppy
