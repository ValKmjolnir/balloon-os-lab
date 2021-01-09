# ballon system bootsect.s
# copyright @ValKmjolnir
# 2021

.code16

.equ BOOTSEG, 0x07c0 # i386 begins running from 0x07c0:0x0000->0x07c00
.equ INITSEG, 0x9000 # move boot to 0x9000:0x0000->0x90000
.equ SETUPSEG,0x9020 # begin address of setup.s
.equ SYSSEG,  0x1000 # begin address of system module
.equ SYSEND,  0x9000 # end address of system module 512k

# cs code segment
# ds data segment
# es extra segment
# ss stack segment
# fs add in 80386
# gs add in 80386
# sp stack pointer

	ljmp $BOOTSEG,$bootstart # cs:ip ($BOOTSEG<<4)+$bootstart

bootstart:
	mov $BOOTSEG,%ax
	mov %ax,%ds              # ds:di 0x07c00
	mov $INITSEG,%ax
	mov %ax,%es              # es:si 0x90000
	xor %di,%di              # di=0
	xor %si,%si              # si=0
	mov $0x100,%cx           # movsw:cx(0x100) word from ds:di to es:si
	rep
	movsw
	ljmp $INITSEG,$stackset # cs:ip ($INITSEG<<4)+$stackset

stackset:
	mov %cs,%ax       # ax=INITSEG
	mov %ax,%ds       # ds=ax
	mov %ax,%es       # es=ax
	mov %ax,%ss       # ss=ax
	mov %ax,%fs       # fs=ax
	mov %ax,%gs       # gs=ax
	mov $0xff00,%sp   # sp=0xff00 ss:sp ($INITSEG<<4)+0xff00

start:
	mov $0x03,%ah     # 0x03 read cursor position
	xor %bh,%bh       # set page 0
	int $0x10         # BIOS video service

	mov $msg,%bp      # string address es:bp ($INITSEG<<4)+$msg
	mov $0x1301,%ax   # write string,move cursor
	mov $0x0007,%bx   # page 0(bh 0x00),black background/white characters(bl 0x07)
	mov $28,%cx       # str length
	int $0x10         # BIOS video service

load_setup:
	mov $0x0000,%dx   # dh (head 0x00)  dl (drive 0x00[floppy])
	mov $0x0002,%cx   # ch (track 0x00) cl (begin from sector 0x02)
	mov $0x0204,%ax   # ah (read 0x02)  al (read 0x04 sectors)
	mov $0x0200,%bx   # read setup to es:bx (0x9000<<4)+0x0200=0x90200
	int $0x13         # BIOS drive service
	jnc load_success  # carry flag will be 1 if failed
	
	mov $0x0000,%dx
	mov $0x0000,%ax   # ah (0x00 reset drive)
	int $0x13         # BIOS drive service
	jmp load_setup    # if failed,try again

load_success:
	mov $0x03,%ah     # read cursor position
	xor %bh,%bh       # page 0
	int $0x10         # BIOS video service
	mov $success,%bp  # str address es:bp
	mov $0x1301,%ax   # write str,move cursor
	mov $0x0007,%bx   # page 0(bh),black back/white char(0x07 bl)
	mov $15,%cx       # str length
	int $0x10         # BIOS video service
	
	ljmp $SETUPSEG,$0 # cs:ip=0x90200
msg:
	.ascii "starting balloon system..."
	.byte 13,10       # \r\n
success:
	.ascii "setup loaded."
	.byte 13,10       # \r\n

.=510
signature:
	.word 0xaa55      # magic number for MBR

