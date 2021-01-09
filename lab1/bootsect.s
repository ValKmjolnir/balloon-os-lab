# ballon system bootsect.s
# copyright @ValKmjolnir
# 2020

.code16
.global bootstart

.equ BOOTSEG, 0x07c0
# begin from 0x07c0:0x0000->0x07c00
.equ INITSEG, 0x9000
# jump to 0x9000:0x0000->0x90000 then bootsect 0x90000~0x901ff
.equ SETUPSEG,0x9020
# beginning address of setup.s
.equ SYSSEG, 0x1000
# beginning address of system
.equ SYSEND, 0x8000
# system ends at 0x70000=448kb


ljmp $BOOTSEG,$bootstart

bootstart:
	mov $BOOTSEG,%ax
	mov %ax,%ds
	mov $INITSEG,%ax
	mov %ax,%es
	xor %di,%di
	xor %si,%si
	mov $0x100,%cx
	rep
	movsw
	ljmp $INITSEG,$stackset
	# copy operation use rep movsw 256(cx) times to move 512(256*2) bytes from ds:di to es:si
	# copy bootsect from 0x07c00 to 0x90000 and jump to 0x90000+stackset
	# ljmp $INITSEG,$stackset -> cs=INITSEG ip=stackset
stackset:
	mov %cs,%ax     # ax=INITSEG
	mov %ax,%ds     # ds=ax
	mov %ax,%es     # es=ax
	mov %ax,%ss     # ss=ax
	mov $0xff00,%sp # sp=0xff00

start:
	mov $0x03,%ah   # read cursor position
	xor %bh,%bh     # set page 0
	int $0x10       # BIOS video service

	mov $INITSEG,%ax
	mov %ax,%es     # es:bp points to the string

	mov $sysmsg,%bp # set string address
	mov $0x1301,%ax # write string,move cursor
	mov $0x0007,%bx # page 0,black background/white characters
	mov $28,%cx     # length of string
	int $0x10       # BIOS video service

die:
	hlt
	jmp die         # infinite loop

sysmsg:
	.ascii "Starting Balloon System..."
	.byte 13,10

.=510
signature:
	.word 0xaa55

