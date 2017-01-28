;this document has modified
;last 2014.8.22
%include	"M_pm.inc"
	org 0100h	;it can be replaced to 07c00h
	jmp LABEL_BEGIN

[SECTION .gdt]

LABEL_GDT:		Descriptor		0,		0,0
LABEL_NORMAL:		Descriptor		0,	   0ffffh,DA_DRW
LABEL_DATA:		Descriptor		0,	DataLen-1,DA_DRW
LABEL_STACK:		Descriptor		0,     TopOfStack,DA_DRWA+DA_32
LABEL_DESC_CODE_DEST:	Descriptor		0,  DestCodeLen-1,DA_32+DA_C
LABEL_DESC_CODE16:	Descriptor		0,	   0ffffh,DA_C
LABEL_DESC_CODE32:	Descriptor		0,    Code32Len-1,DA_C+DA_32
LABEL_DESC_CODE_RING3:	Descriptor		0, CodeRing3Len-1,DA_C+DA_32+DA_DPL3
LABEL_DESC_STACK3:	Descriptor		0,    TopOfStack3,DA_DRWA+DA_32+DA_DPL3
LABEL_DESC_TSS:		Descriptor		0,	 TssLen-1,DA_386TSS

LABEL_LDT:		Descriptor		0,	 LdtLen-1,DA_LDT
LABEL_VIDEO:		Descriptor	  0B8000h,	   0ffffh,DA_DRW+DA_DPL3

LBAEL_CALL_GATE_TEST:	Gate	 SelectorCodeDest,	0,	0,DA_386CGate+DA_DPL3


GdtLen		equ		$-LABEL_GDT
GdtPtr		dw	GdtLen-1
		dd	0
;End of GDT

;Selector in .gdt
SelectorNormal		equ	LABEL_NORMAL		-LABEL_GDT
SelectorData		equ	LABEL_DATA		-LABEL_GDT
SelectorStack		equ	LABEL_STACK		-LABEL_GDT
SelectorCode16		equ	LABEL_DESC_CODE16	-LABEL_GDT
SelectorCode32		equ	LABEL_DESC_CODE32	-LABEL_GDT
SelectorLdt		equ	LABEL_LDT		-LABEL_GDT
SelectorVideo		equ	LABEL_VIDEO		-LABEL_GDT
SelectorStack3		equ	LABEL_DESC_STACK3	-LABEL_GDT+SA_RPL3
SelectorCodeRing3	equ	LABEL_DESC_CODE_RING3	-LABEL_GDT+SA_RPL3
SelectorTss		equ	LABEL_DESC_TSS		-LABEL_GDT
SelectorCodeDest	equ	LABEL_DESC_CODE_DEST	-LABEL_GDT

SelectorGate		equ	LBAEL_CALL_GATE_TEST	-LABEL_GDT+SA_RPL3

;End of Selector


[SECTION .data]
ALIGN 32
[BITS 32]
LABEL_SEG_DATA:
SPValueInRealMode	dw	0

PMMessage:		db	"In Protect Mode now. ^-^", 0	; 进入保护模式后显示此字符串
OffsetPMMessage		equ	PMMessage - $$

DataLen		equ		$-LABEL_SEG_DATA

;End of data

[SECTION .stack]
ALIGN 32
[BITS 32]
LABEL_SEG_STACK:
	times	512	db	0
TopOfStack	equ	$-LABEL_SEG_STACK-1

;End of stack

[SECTION .stack3]
ALIGN 32
[BITS 32]
LABEL_SEG_STACK3:
	times	512	db	0
TopOfStack3	equ	$-LABEL_SEG_STACK3-1


[SECTION .tss]
ALIGN 32
[BITS 32]
LABEL_SEG_TSS:
	dd	0			;back
	dd	TopOfStack		;esp0
	dd	SelectorStack		;ss0
	dd	0			;esp1
	dd	0			;ss1
	dd	0			;esp2
	dd	0			;ss2

	dd	0			;gr3(pdbr)
	dd	0			;eip
	dd	0			;eflags
	dd	0			;eax
	dd	0			;ecx
	dd	0			;edx
	dd	0			;ebx
	dd	0			;esp
	dd	0			;ebp
	dd	0			;esi
	dd	0			;edi

	dd	0			;es
	dd	0			;cs
	dd	0			;ss
	dd	0			;ds
	dd	0			;fs
	dd	0			;gs
	dd	0			;LDT

	dw	0			;调试陷阱标志
	dw	$-LABEL_SEG_TSS+2	;I/O位图基址
	db	0ffh			;I/O位图结束标志

TssLen		equ	$-LABEL_SEG_TSS



[SECTION .s16]
[BITS 16]
LABEL_BEGIN:
	mov	ax,cs
	mov	ds,ax
	mov	es,ax
	mov	ss,ax

	mov	sp,0100h

	mov	[LABEL_GO_BACK_TO_REAL+3],ax
	mov	[SPValueInRealMode],sp

	;.s16
	mov	ax,cs
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

	;.data
	xor	eax,eax
	mov	ax,cs
	shl	eax,4
	add	eax,LABEL_SEG_DATA
	mov	word [LABEL_DATA+2],ax
	shr	eax,16
	mov	byte [LABEL_DATA+4],al
	mov	byte [LABEL_DATA+7],ah

	;.stack
	xor	eax,eax
	mov	ax,cs
	shl	eax,4
	add	eax,LABEL_SEG_STACK
	mov	word [LABEL_STACK+2],ax
	shr	eax,16
	mov	byte [LABEL_STACK+4],al
	mov	byte [LABEL_STACK+7],ah

	;.ldt in.gdt
	xor	eax,eax
	mov	ax,cs
	shl	eax,4
	add	eax,LABEL_SEG_LDT
	mov	word [LABEL_LDT+2],ax
	shr	eax,16
	mov	byte [LABEL_LDT+4],al
	mov	byte [LABEL_LDT+7],ah

	;.ldt
	xor	eax,eax
	mov	ax,cs
	shl	eax,4
	add	eax,LABEL_LDT_SEG_CODE
	mov	word [LABEL_LDT_DESC_CODE+2],ax
	shr	eax,16
	mov	byte [LABEL_LDT_DESC_CODE+4],al
	mov	byte [LABEL_LDT_DESC_CODE+7],ah

	;.Gate
	xor	eax,eax
	mov	ax,cs
	shl	eax,4
	add	eax,LABEL_CALL_GATE
	mov	word [LABEL_DESC_CODE_DEST+2],ax
	shr	eax,16
	mov	byte [LABEL_DESC_CODE_DEST+4],al
	mov	byte [LABEL_DESC_CODE_DEST+7],ah

	;TSS
	xor	eax,eax
	mov	ax,cs
	shl	eax,4
	add	eax,LABEL_SEG_TSS
	mov	word [LABEL_DESC_TSS+2],ax
	shr	eax,16
	mov	byte [LABEL_DESC_TSS+4],al
	mov	byte [LABEL_DESC_TSS+7],ah

	;stack3
	xor	eax,eax
	mov	ax,cs
	shl	eax,4
	add	eax,LABEL_SEG_STACK3
	mov	word [LABEL_DESC_STACK3+2],ax
	shr	eax,16
	mov	byte [LABEL_DESC_STACK3+4],al
	mov	byte [LABEL_DESC_STACK3+7],ah

	;codering3
	xor	eax,eax
	mov	ax,cs
	shl	eax,4
	add	eax,LABEL_SEG_CODE_RING3
	mov	word [LABEL_DESC_CODE_RING3+2],ax
	shr	eax,16
	mov	byte [LABEL_DESC_CODE_RING3+4],al
	mov	byte [LABEL_DESC_CODE_RING3+7],ah


	;End of


	xor	eax,eax
	mov	ax,cs
	shl	eax,4
	add	eax,LABEL_GDT
	mov	dword [GdtPtr+2],eax

	lgdt	[GdtPtr]

	cli

	in	al,92h
	or	al,00000010b
	out	92h,al

	mov	eax,cr0
	or	al,1
	mov	cr0,eax


	jmp	SelectorCode32:0

LABEL_REAL_ENTRY:
	mov	ax,cs
	mov	es,ax
	mov	ds,ax
	mov	ss,ax

	mov	sp,[SPValueInRealMode]

	in	al,92h
	and	al,11111101b
	out	92h,al

	sti

	mov	ax,4c00h
	int	21h

;End of .s16

[SECTION .s32]
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
.1:
	lodsb
	test	al,al
	jz	.2
	mov	[gs:edi],ax
	add	edi,2
	jmp	.1

.2:
	call	DispReturn

	mov	ax,SelectorTss
	ltr	ax

	push	SelectorStack3
	push	TopOfStack3
	push	SelectorCodeRing3
	push	0

	retf


	
DispReturn:
	push	eax
	push	ebx
	mov	eax,edi
	mov	bl,160
	div	bl
	and	eax,0ffh
	inc	eax
	mov	bl,160
	mul	bl
	mov	edi,eax
	pop	ebx
	pop	eax
	ret



Code32Len		equ	$-LABEL_SEG_CODE32
;End of .s32

[SECTION .ring3]
[BITS 32]
LABEL_SEG_CODE_RING3:
	mov	ax,SelectorVideo
	mov	gs,ax

	mov	edi,(80*13+0)*2
	mov	ah,0Ch
	mov	al,'3'
	mov	[gs:edi],ax

	call	SelectorGate:0

	jmp	$
CodeRing3Len	equ	$-LABEL_SEG_CODE_RING3


[SECTION .s16code]
ALIGN 32
[BITS 16]
LABEL_SEG_CODE16:
	mov	ax,SelectorNormal
	mov	fs,ax
	mov	es,ax
	mov	gs,ax
	mov	ds,ax
	mov	ss,ax

	mov	eax,cr0
	and	eax,11111110b
	mov	cr0,eax

LABEL_GO_BACK_TO_REAL:
	jmp	0:LABEL_REAL_ENTRY

Code16Len	equ	$-LABEL_SEG_CODE16
;End of .s16code


[SECTION .testgate]
[BITS 32]
LABEL_CALL_GATE:
	mov	ax,SelectorVideo
	mov	gs,ax

	mov	edi,(80*12+0)*2
	mov	ah,0Ch
	mov	al,'C'
	mov	[gs:edi],ax

	mov	ax,SelectorLdt
	lldt	ax


	jmp	SelectorLdtCode:0


DestCodeLen	equ	$-LABEL_CALL_GATE
;



[SECTION .ldt]
ALIGN 32
LABEL_SEG_LDT:
LABEL_LDT_DESC_CODE:		Descriptor	0,		LdtCodeLen-1,DA_C+DA_32

LdtLen		equ	$-LABEL_SEG_LDT
;End of .ldt


;Selector in .ldt

SelectorLdtCode 		equ	LABEL_LDT_DESC_CODE	- LABEL_SEG_LDT +SA_TIL

;End of .ldt


[SECTION .la]
ALIGN 32
[BITS 32]
LABEL_LDT_SEG_CODE:
	mov	ax,SelectorVideo
	mov	gs,ax

	mov	edi,(80*14+0)*2
	mov	ah,0Ch
	mov	al,'L'
	mov	[gs:edi],ax

	jmp	SelectorCode16:0

LdtCodeLen	equ	$-LABEL_LDT_SEG_CODE
;End of .la