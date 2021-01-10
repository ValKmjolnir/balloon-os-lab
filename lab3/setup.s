# ballon system setup.s
# copyright @ValKmjolnir
# 2021

.code16
.equ SETUPSEG,0x9020      # begin address of setup.s

setup:
	mov $0x0013,%ax   # vga 320x200 256 color
	int $0x10         # BIOS video service
	
	mov $0x03,%ah     # read cursor position
	xor %bh,%bh       # page 0
	int $0x10         # BIOS video service
	
	mov %cs,%ax
	mov %ax,%es

	mov $msg,%bp      # str address es:bp
	mov $0x1301,%ax   # write str,move cursor
	mov $0x0007,%bx   # page 0(bh),black back/white char(0x07 bl)
	mov $17,%cx       # str length
	int $0x10         # BIOS video service

loop:
	hlt
	jmp loop

msg:
	.ascii "setup complete."
	.byte 13,10
