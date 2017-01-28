org	0100h
	jmp	LABEL_START

%include	"fat12hdr.inc"
%include	"load.inc"
%include	"pm.inc"

LABEL_GDT:		Descriptor		0,		0,0
LABEL_DESC_FLAT_C:	Descriptor	  0fffffh,DA_CR|DA_32|DA_LIMIT_4K
LABEL_DESC_FLAT_RW:	Descriptor	  0fffffh,DA_RAW|DA_32|DA_LIMIT_4K
LABEL_DESC_VIDEO:	Descriptor	  0B8000h,DA_RAW|DA_DPL3

GdtLen			equ	$-LABEL_GDT
GdtPtr			dw	GdtLen-1
			dd	BaseOfLoaderPhyAddr+LABEL_GDT

BaseOfStack	equ	0100h
PageDirBase	equ	100000h
PageTblBase	equ	101000h


LABEL_START:
	mov	ax,cs
	mov	ds,ax
	mov	es,ax
	mov	ss,ax

	mov	sp,BseeOfStack

	mov	dh,0
	call	DispStrRealMode

	mov	ebx,0
	mov	di,_MemChkBuf
.MemChkLoop:
	mov	eax,0E820h
	mov	ecx,20
	mov	edx,0534D4150h
	int	15h
	jc	.MemChkFail
	add	di,20
	inc	dword [_dwMCRNumber]
	cmp	ebx,0
	jne	.MemChkloop
	jmp	.MemChkOK
.MemChkFail:
	mov	dword [_dwMCRNumber],0
.MemChkOK:
	