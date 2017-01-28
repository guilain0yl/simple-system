;this document has modified,some bugs
;last 2014.8.25

%include	"M_pm.inc"

PageDirBase0		equ	200000h	; ҳĿ¼��ʼ��ַ:	2M
PageTblBase0		equ	201000h	; ҳ��ʼ��ַ:		2M +  4K
PageDirBase1		equ	210000h	; ҳĿ¼��ʼ��ַ:	2M + 64K
PageTblBase1		equ	211000h	; ҳ��ʼ��ַ:		2M + 64K + 4K

LinearAddrDemo	equ	00401000h
ProcFoo		equ	00401000h
ProcBar		equ	00501000h
ProcPagingDemo	equ	00301000h

	org 0100h
	jmp LABEL_BEGIN
[SECTION .gdt]
;gdt

LABEL_GDT:		Descriptor		0,			0,0
LABEL_DESC_NORMAL:	Descriptor		0,		   0ffffh,DA_DRW
LABEL_DESC_CODE32:	Descriptor		0,	   SegCode32Len-1,DA_C+DA_32
LABEL_DESC_CODE16:	Descriptor		0,		   0ffffh,DA_C

LABEL_DESC_FLAT_C:	Descriptor		0,		   0ffffh,DA_CR|DA_32|DA_LIMIT_4K
LABEL_DESC_FLAT_RW:	Descriptor		0,		   0ffffh,DA_DRW|DA_LIMIT_4K

LABEL_DESC_DATA:	Descriptor		0,	     SegDataLen-1,DA_DRW
LABEL_DESC_STACK:	Descriptor		0,	       TopOfStack,DA_DRWA+DA_32
LABEL_DESC_VIDEO:	Descriptor	  0b8000h,		   0ffffh,DA_DRW

GdtLen		equ	$-LABEL_GDT
GdtPtr		dw	GdtLen-1
		dd	0

SelectorNormal	equ	LABEL_DESC_NORMAL	-	LABEL_GDT
SelectorCode32	equ	LABEL_DESC_CODE32	-	LABEL_GDT
SelectorCode16	equ	LABEL_DESC_CODE16	-	LABEL_GDT

SelectorFlatC	equ	LABEL_DESC_FLAT_C	-	LABEL_GDT
SelectorFlatRW	equ	LABEL_DESC_FLAT_RW	-	LABEL_GDT

SelectorData	equ	LABEL_DESC_DATA		-	LABEL_GDT
SelectorStack	equ	LABEL_DESC_STACK	-	LABEL_GDT
SelectorVideo	equ	LABEL_DESC_VIDEO	-	LABEL_GDT

;End of .gdt

[SECTION .data1]
ALIGN	32
[BITS 32]
LABEL_DATA:
;
_szPMMessage:		db	"In Protect Mode now ^_^",0Ah,0Ah,0
_szMemChkTitle:		db	"BaseAddrL  BaseAddrH  LengthLow  LengthHigh  Type",0
_szRAMSize:		db	"RAM Szie:",0
_szReturn:		db	0Ah,0
;
;
;
_wSPValueRealMode:	dw	0;ESP
_dwMCRNumber:		dd	0;Memory check result
_dwDispPos:		dd	(80*6+0)*2
_dwMemSize:		dd	0
_ARDStruct:
	_dwBaseAddrLow:		dd	0
	_dwBaseAddrHigh:	dd	0
	_dwLengthLow:		dd	0
	_dwLengthHigh:		dd	0
	_dwType:		dd	0
_PageTableNumber		dd	0
_MemChkBuf:	times	256	db	0

;
;
szPMMessage		equ	_szPMMessage	-$$
szMemChkTitle		equ	_szMemChkTitle	-$$
szRAMSize		equ	_szRAMSize	-$$
szReturn		equ	_szReturn	-$$
dwDispPos		equ	_dwDispPos	-$$
dwMemSize		equ	_dwMemSize	-$$
dwMCRNumber		equ	_dwMCRNumber	-$$
ARDStruct		equ	_ARDStruct	-$$
	dwBaseAddrLow	equ	_dwBaseAddrLow	-$$
	dwBaseAddrHigh	equ	_dwBaseAddrHigh	-$$
	dwLengthLow	equ	_dwLengthLow	-$$
	dwLengthHigh	equ	_dwLengthHigh	-$$
	dwType		equ	_dwType		-$$
MemChkBuf		equ	_MemChkBuf	-$$
PageTableNumber		equ	_PageTableNumber-$$


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
	mov	[_wSPValueRealMode],sp

	;get mem size
	mov	ebx,0
	mov	di,_MemChkBuf
.loop:
	mov	eax,0E820h
	mov	ecx,20
	mov	edx,0534D4150h	;SMAP
	int	15h
	jc	LABEL_MEM_CHK_FAIL	;CF=1 error  jmp
	add	di,20
	inc	dword [_dwMCRNumber]
	cmp	ebx,0	;ebx==0 zf=1
	jne	.loop
	jmp	LABEL_MEM_CHK_OK
LABEL_MEM_CHK_FAIL:
	mov	dword [_dwMCRNumber],0
LABEL_MEM_CHK_OK:

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
	mov	sp,[_wSPValueRealMode]

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
	mov	es,ax
	mov	ax,SelectorVideo
	mov	gs,ax

	mov	ax,SelectorStack
	mov	ss,ax

	mov	esp,TopOfStack


	push	szPMMessage
	call	DispStr
	add	esp,4

	push	szMemChkTitle
	call	DispStr
	add	esp,4

	call	DispMemSize

	call	PagingDemo



	jmp	SelectorCode16:0

SetupPaging:
	; �����ڴ��С����Ӧ��ʼ������PDE�Լ�����ҳ��
	xor	edx, edx
	mov	eax, [dwMemSize]
	mov	ebx, 400000h	; 400000h = 4M = 4096 * 1024, һ��ҳ���Ӧ���ڴ��С
	div	ebx
	mov	ecx, eax	; ��ʱ ecx Ϊҳ��ĸ�����Ҳ�� PDE Ӧ�õĸ���
	test	edx, edx
	jz	.no_remainder
	inc	ecx		; ���������Ϊ 0 ��������һ��ҳ��
.no_remainder:
	mov	[PageTableNumber], ecx	; �ݴ�ҳ�����

	; Ϊ�򻯴���, �������Ե�ַ��Ӧ��ȵ������ַ. ���Ҳ������ڴ�ն�.

	; ���ȳ�ʼ��ҳĿ¼
	mov	ax, SelectorFlatRW
	mov	es, ax
	mov	edi, PageDirBase0	; �˶��׵�ַΪ PageDirBase0
	xor	eax, eax
	mov	eax, PageTblBase0 | PG_P  | PG_USU | PG_RWW
.1:
	stosd
	add	eax, 4096		; Ϊ�˼�, ����ҳ�����ڴ�����������.
	loop	.1

	; �ٳ�ʼ������ҳ��
	mov	eax, [PageTableNumber]	; ҳ�����
	mov	ebx, 1024		; ÿ��ҳ�� 1024 �� PTE
	mul	ebx
	mov	ecx, eax		; PTE���� = ҳ����� * 1024
	mov	edi, PageTblBase0	; �˶��׵�ַΪ PageTblBase0
	xor	eax, eax
	mov	eax, PG_P  | PG_USU | PG_RWW
.2:
	stosd
	add	eax, 4096		; ÿһҳָ�� 4K �Ŀռ�
	loop	.2

	mov	eax, PageDirBase0
	mov	cr3, eax
	mov	eax, cr0
	or	eax, 80000000h
	mov	cr0, eax
	jmp	short .3
.3:
	nop

	ret
; ��ҳ����������� ----------------------------------------------------------


; ���Է�ҳ���� --------------------------------------------------------------
PagingDemo:
	mov	ax, cs
	mov	ds, ax
	mov	ax, SelectorFlatRW
	mov	es, ax

	push	LenFoo
	push	OffsetFoo
	push	ProcFoo
	call	MemCpy
	add	esp, 12

	push	LenBar
	push	OffsetBar
	push	ProcBar
	call	MemCpy
	add	esp, 12

	push	LenPagingDemoAll
	push	OffsetPagingDemoProc
	push	ProcPagingDemo
	call	MemCpy
	add	esp, 12

	mov	ax, SelectorData
	mov	ds, ax			; ���ݶ�ѡ����
	mov	es, ax

	call	SetupPaging		; ������ҳ

	call	SelectorFlatC:ProcPagingDemo
	call	PSwitch			; �л�ҳĿ¼���ı��ַӳ���ϵ
	call	SelectorFlatC:ProcPagingDemo

	ret
; ---------------------------------------------------------------------------


; �л�ҳ�� ------------------------------------------------------------------
PSwitch:
	; ��ʼ��ҳĿ¼
	mov	ax, SelectorFlatRW
	mov	es, ax
	mov	edi, PageDirBase1	; �˶��׵�ַΪ PageDirBase1
	xor	eax, eax
	mov	eax, PageTblBase1 | PG_P  | PG_USU | PG_RWW
	mov	ecx, [PageTableNumber]
.1:
	stosd
	add	eax, 4096		; Ϊ�˼�, ����ҳ�����ڴ�����������.
	loop	.1

	; �ٳ�ʼ������ҳ��
	mov	eax, [PageTableNumber]	; ҳ�����
	mov	ebx, 1024		; ÿ��ҳ�� 1024 �� PTE
	mul	ebx
	mov	ecx, eax		; PTE���� = ҳ����� * 1024
	mov	edi, PageTblBase1	; �˶��׵�ַΪ PageTblBase1
	xor	eax, eax
	mov	eax, PG_P  | PG_USU | PG_RWW
.2:
	stosd
	add	eax, 4096		; ÿһҳָ�� 4K �Ŀռ�
	loop	.2

	; �ڴ˼����ڴ��Ǵ��� 8M ��
	mov	eax, LinearAddrDemo
	shr	eax, 22
	mov	ebx, 4096
	mul	ebx
	mov	ecx, eax
	mov	eax, LinearAddrDemo
	shr	eax, 12
	and	eax, 03FFh	; 1111111111b (10 bits)
	mov	ebx, 4
	mul	ebx
	add	eax, ecx
	add	eax, PageTblBase1
	mov	dword [es:eax], ProcBar | PG_P | PG_USU | PG_RWW

	mov	eax, PageDirBase1
	mov	cr3, eax
	jmp	short .3
.3:
	nop

	ret
;;
PagingDemoProc:
OffsetPagingDemoProc	equ	PagingDemoProc - $$
	mov	eax, LinearAddrDemo
	call	eax
	retf
LenPagingDemoAll	equ	$ - PagingDemoProc

foo:
OffsetFoo		equ	foo - $$
	mov	ah, 0Ch			; 0000: �ڵ�    1100: ����
	mov	al, 'F'
	mov	[gs:((80 * 17 + 0) * 2)], ax	; ��Ļ�� 17 ��, �� 0 �С�
	mov	al, 'o'
	mov	[gs:((80 * 17 + 1) * 2)], ax	; ��Ļ�� 17 ��, �� 1 �С�
	mov	[gs:((80 * 17 + 2) * 2)], ax	; ��Ļ�� 17 ��, �� 2 �С�
	ret
LenFoo			equ	$ - foo

bar:
OffsetBar		equ	bar - $$
	mov	ah, 0Ch			; 0000: �ڵ�    1100: ����
	mov	al, 'B'
	mov	[gs:((80 * 18 + 0) * 2)], ax	; ��Ļ�� 18 ��, �� 0 �С�
	mov	al, 'a'
	mov	[gs:((80 * 18 + 1) * 2)], ax	; ��Ļ�� 18 ��, �� 1 �С�
	mov	al, 'r'
	mov	[gs:((80 * 18 + 2) * 2)], ax	; ��Ļ�� 18 ��, �� 2 �С�
	ret
LenBar			equ	$ - bar



DispMemSize:
	push	esi
	push	edi
	push	ecx

	mov	esi,MemChkBuf
	mov	ecx,[dwMCRNumber]
.loop:
	mov	edx,5
	mov	edi,ARDStruct
.1:
	push	dword [esi]
	call	DispInt
	pop	eax
	stosd
	add	esi,4
	dec	edx
	cmp	edx,0
	jnz	.1
	call	DispReturn
	cmp	dword [dwType],1
	jne	.2
	mov	eax,[dwBaseAddrLow]
	add	eax,[dwLengthLow]
	cmp	eax,[dwMemSize]
	jb	.2
	mov	[dwMemSize],eax
.2:
	loop	.loop

	call	DispReturn
	push	szRAMSize
	call	DispStr
	add	esp,4

	push	dword [dwMemSize]
	call	DispInt
	add	esp,4

	pop	ecx
	pop	edi
	pop	esi
	ret

%include	"lib.inc"




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
	and	eax,7FFFFFFEh;0111 1111 1111 1111 1111 1111 1111 1110
	mov	cr0,eax

LABEL_GO_BACK_TO_REAL:
	jmp	0:LABEL_REAL_ENTRY

Code16Len	equ	$-LABEL_SEG_CODE16