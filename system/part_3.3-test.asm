;this document has modified
;last 2014.8.19
%include	"M_pm.inc"

	org 0100h
	jmp LABEL_BEGIN
[SECTION .gdt]
;gdt

LABEL_GDT:		Descriptor	  0,			0,0
LABEL_DESC_NORMAL:	Descriptor	  0,		   0ffffh,DA_DRW
LABEL_DESC_CODE32:	Descriptor	  0,	   SegCode32Len-1,DA_C+DA_32
LABEL_DESC_CODE16:	Descriptor	  0,		   0ffffh,DA_C
LABEL_DESC_DATA:	Descriptor	  0,	     SegDataLen-1,DA_DRW+DA_DPL1
LABEL_DESC_STACK:	Descriptor	  0,	       TopOfStack,DA_DRWA+DA_32
LABEL_DESC_LDT:		Descriptor	  0,	         LdtLen-1,DA_LDT
LABEL_DESC_VIDEO:	Descriptor  0B8000h,		   0ffffh,DA_DRW

GdtLen		equ	$-LABEL_GDT
GdtPtr		dw	GdtLen-1
		dd	0

SelectorNormal	equ	LABEL_DESC_NORMAL	-	LABEL_GDT
SelectorCode32	equ	LABEL_DESC_CODE32	-	LABEL_GDT
SelectorCode16	equ	LABEL_DESC_CODE16	-	LABEL_GDT
SelectorData	equ	LABEL_DESC_DATA		-	LABEL_GDT	+SA_RPL3
SelectorStack	equ	LABEL_DESC_STACK	-	LABEL_GDT
SelectorLDT	equ	LABEL_DESC_LDT		-	LABEL_GDT
SelectorVideo	equ	LABEL_DESC_VIDEO	-	LABEL_GDT

;End of .gdt

[SECTION .data]
ALIGN	32
[BITS 32]
LABEL_DATA:
SPValueRealMode:	dw	0;ESP

PMMessage:		db	"In Protect Mode now ^_^",0
OffsetPMMessage:	equ	PMMessage-$$
StrTest:		db	"ABCDEFGHIJKLMNOPQRSTUVWXYZ", 0
OffsetStrTest		equ	StrTest - $$
SegDataLen		equ	$-LABEL_DATA
;End of .data

[SECTION .gs]
ALIGN 32
[BITS 32]
LABEL_STACK:
	times	512 db 0

TopOfStack	equ	$-LABEL_STACK-1
;End of .stack

[SECTION .s16]
[BITS 16]
LABEL_BEGIN:
	mov	ax,cs
	mov	ds,ax
	mov	ss,ax
	mov	es,ax
	mov	sp,0100h

	mov	[LABEL_GO_BACK_TO_REAL+3],ax
	mov	[SPValueRealMode],sp


	;.s16
	mov	ax,cs				;no must
	movzx	eax,ax
	shl	eax,4
	add	eax,LABEL_SEG_CODE16
	mov	word [LABEL_DESC_CODE16+2],ax
	shr	eax,16
	mov	byte [LABEL_DESC_CODE16+4],al
	mov	byte [LABEL_DESC_CODE16+7],ah

	;.s32
	xor	eax,eax
	mov	ax,cs
	shl	eax,4
	add	eax,LABEL_SEG_CODE32
	mov	word [LABEL_DESC_CODE32+2],ax
	shr	eax,16
	mov	byte [LABEL_DESC_CODE32+4],al
	mov	byte [LABEL_DESC_CODE32+7],ah

	;.lgt in .gdt
	xor	eax,eax
	mov	ax,ds
	shl	eax,4
	add	eax,LABEL_LDT
	mov	word [LABEL_DESC_LDT+2],ax
	shr	eax,16
	mov	byte [LABEL_DESC_LDT+4],al
	mov	byte [LABEL_DESC_LDT+7],ah

	;.data
	xor	eax,eax
	mov	ax,ds
	shl	eax,4
	add	eax,LABEL_DATA
	mov	word [LABEL_DESC_DATA+2],ax
	shr	eax,16
	mov	byte [LABEL_DESC_DATA+4],al
	mov	byte [LABEL_DESC_DATA+7],ah

	;.stack
	xor	eax,eax
	mov	ax,ds
	shl	eax,4
	add	eax,LABEL_STACK
	mov	word [LABEL_DESC_STACK+2],ax
	shr	eax,16
	mov	byte [LABEL_DESC_STACK+4],al
	mov	byte [LABEL_DESC_STACK+7],ah

	;.ldt
	xor	eax,eax
	mov	ax,ds
	shl	eax,4
	add	eax,LABEL_CODE_A
	mov	word [LABEL_LDT_DESC_CODEA+2],ax
	shr	eax,16
	mov	byte [LABEL_LDT_DESC_CODEA+4],al
	mov	byte [LABEL_LDT_DESC_CODEA+7],ah

	xor	eax,eax
	mov	ax,ds
	shl	eax,4
	add	eax,LABEL_GDT
	mov	dword [GdtPtr+2],eax

	lgdt	[GdtPtr]

	cli

	in	al,92h
	or	al,00000010b
	out	92h,al

	mov	eax,cr0
	or	eax,1
	mov	cr0,eax

	jmp	dword SelectorCode32:0


LABEL_REAL_ENTRY:
	mov	ax,cs
	mov	ss,ax
	mov	es,ax
	mov	ds,ax
	mov	sp,[SPValueRealMode]

	in	al,92h
	and	al,11111101b
	out	92h,al

	sti

	mov	ax,4c00h
	int	21h

;End of .16
[SECTION .32]
[BITS 32]
LABEL_SEG_CODE32:
	mov	ax,SelectorData
	mov	ds,ax
	
	mov	ax,SelectorVideo
	mov	gs,ax
	mov	ax,SelectorStack
	mov	ss,ax

	mov	esp,TopOfStack

	mov	ah,0Ch
	xor	esi,esi
	xor	edi,edi
	mov	esi,OffsetPMMessage
	mov	edi,(80*10+0)*2

	cld

.1:	lodsb
	test	al,al
	jz	.2
	mov	[gs:edi],ax
	add	edi,2
	jmp	.1

.2:	call	DispReturn

	mov	ax,SelectorLDT
	lldt	ax

	jmp	SelectorLDTCodeA:0


DispReturn:
	push	eax
	push	ebx
	mov	eax,edi
	mov	bl,160
	div	bl			;商在al中，余数为ah
	and	eax,0FFh		;商即为行数，余数即为列数
	inc	eax			;下一行
	mov	bl,160			
	mul	bl			;积在ax中，即为下一行开始数，余数被清零
	mov	edi,eax
	pop	ebx
	pop	eax

	ret

SegCode32Len	equ	$-LABEL_SEG_CODE32

[SECTION .s16code]
ALIGN 32
[BITS 16]
LABEL_SEG_CODE16:
	mov	ax,SelectorNormal
	mov	ds,ax
	mov	es,ax
	mov	ss,ax
	mov	fs,ax
	mov	gs,ax

	mov	eax,cr0
	and	al,11111110b
	mov	cr0,eax

LABEL_GO_BACK_TO_REAL:
	jmp	0:LABEL_REAL_ENTRY

Code16Len	equ	$-LABEL_SEG_CODE16

[SECTION .ldt]
ALIGN 32
LABEL_LDT:
LABEL_LDT_DESC_CODEA:		Descriptor	0,		LdtCodeLen-1,DA_C+DA_32

LdtLen		equ	$-LABEL_LDT

SelectorLDTCodeA		equ	LABEL_LDT_DESC_CODEA	- LABEL_LDT +SA_TIL




[SECTION .la]
ALIGN 32
[BITS 32]
LABEL_CODE_A:
	mov	ax,SelectorVideo
	mov	gs,ax

	mov	edi,(80*12+0)*2
	mov	ah,0Ch
	mov	al,'L'
	mov	[gs:edi],ax

	jmp	SelectorCode16:0

LdtCodeLen	equ	$-LABEL_CODE_A