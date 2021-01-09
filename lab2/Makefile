All: Image

.PHONY=clean run-qemu

bootsect:bootsect.s ld_boot.ld
	- @as --32 bootsect.s -o bootsect.o
	- @ld -T ld_boot.ld bootsect.o -o bootsect
	- @objcopy -O binary -j .text bootsect
# code16 bootloader

setup:setup.s ld_boot.ld
	- @as --32 setup.s -o setup.o
	- @ld -T ld_boot.ld setup.o -o setup
	- @objcopy -O binary -j .text setup

Image:bootsect setup
	- @dd if=bootsect of=Image bs=512 count=1
	- @dd if=setup of=Image bs=512 count=4 seek=1
	- @echo "Image built done"
# Image of this system

clean:
	- @rm -f *.o bootsect setup Image

run-qemu:Image
	- @qemu-system-i386 -boot a -fda Image
# -fda running from virtual floppy
