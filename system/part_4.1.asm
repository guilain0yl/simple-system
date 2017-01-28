;2014.8.29

org	07c00h

BaseOfStack		equ	07c00h

BaseOfLoader		equ	09000h
OffsetOfLoader		equ	0100h
RootDirSectors		equ	14
SectorNoOfRootDirectory	equ	19


jmp	short LABEL_START
nop

;just BPB

	BS_OEMName		db	'ForrestY'
	BPB_BytePerSec		dw	0x200	;512
	BPB_SecPerClus		db	0x1
	BPB_RsvdSecCnt		dw	0x1
	BPB_NumFATs		db	0x2
	BPB_RootEntCnt		dw	0xE0	;224
	BPB_TotSec16		dw	0xB40	;2880
	BPB_Media		db	0xF0	;
	BPB_FATSz16		dw	0x9
	BPB_SecPerTrk		dw	0x12
	BPB_NumHeads		dw	0x2
	BPB_HiddSec		dd	0
	BPB_TotSec32		dd	0
	BS_DrvNum		db	0
	BS_Reserved1		db	0
	BS_BootSig		db	0x29
	BS_VolID		dd	0
	BS_VolLab		db	'OrangeS0.02'
	BS_FileSysType		db	'FAT12   '

LABEL_START:
	mov	ax,cs
	mov	es,ax
	mov	ds,ax
	mov	ss,ax
	mov	sp,BaseOfStack

	Call	DispStr
	jmp	$
DispStr:
	mov	ax,BootMessage
	mov	bp,ax
	mov	cx,16
	mov	ax,01301h
	mov	bx,000ch
	mov	dl,0
	int	10h
	ret

BootMessage:	DB	"Hello, OS world!"
times	510-($-$$)	db	0
	dw	0xaa55