org	0100h
BaseOfStack		equ	0100h	;KERNEL.BIN被加载到的位置---短地址
BaseOfKernelFile	equ	08000h	;KERNEL.BIN被加载到的位置---偏移地址

	jmp	LABEL_START
%include	"fat12hdr.inc"

LABEL_START:
	mov	ax,cs
	mov	ds,ax
	mov	es,ax
	mov	ss,ax
	mov	sp,BaseOfStack

	mov	dh,0	;"Loading"
	call	DispStr

	;search kernel.bin in A root

	mov	word [wSectorNo],SectorNoOfRootDirectory
	xor	ah,ah	;
	xor	dl,dl	;软驱复位
	int	13h	;

LABEL_SEARCH_IN_ROOT_DIR_BEGIN:
	cmp	word [wRootDirSizeForLoop],0	;
	jz	LABEL_NO_KERNELBIN		;判断根目录是否读完 读完表示没有找到
	dec	word [wRootDirSizeForLoop]	;
	mov	ax,BaseOfKernelFile
	mov	es,ax
	mov	bx,OffsetOfKernelFile
	mov	ax,[wSectorNo]
	mov	cl,1
	call	ReadSector

	mov	si,KernelFileName
	mov	di,OffsetOfKernelFile
	cld
	mov	dx,10h	;16
LABEL_SEARCH_FOR_KERNELBIN:
	cmp	dx,0
	jz	LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR
	dec	dx
	mov	cx,11
LABEL_CMP_FILENAME:
	cmp	cx,0
	jz	LABEL_FILENAME_FOUND
	dec	cx
	lodsb
	cmp	al,byte [es:di]
	jz	LABEL_GO_ON
	jmp	LABEL_DIFFERENT
LABEL_GO_ON:
	inc	di
	jmp	LABEL_CMP_FILENAME
LABEL_DIFFERENT:
	and	di,0FFE0h			;di是20h的倍数
	add	di,20h				;
	mov	si,KernelFileName		;di+=20h下一条目录条目
	jmp	LABEL_SEARCH_FOR_KERNELBIN	;

LABEL_GOTO_NEXT_SECTOR_IN_ROOT_DIR:
	add	word [wSectorNo],1
	jmp	LABEL_SEARCH_IN_ROOT_DIR_BEGIN

LABEL_NO_KERNELBIN:
	mov	dh,2
	call	DispStr

	jmp	$

LABEL_FILENAME_FOUND:
	mov	ax,RootDirSectors
	and	di,0FFF0h

	push	eax
	mov	eax,[es:di+01Ch]
	mov	dword [dwKernelSize]
	pop	eax
	add	di,01Ah
	mov	cx,word [es:di]
	push	cx
	add	cx,ax
	add	cx,DeltaSectorNo
	mov	ax,BaseOfKernelFile
	mov	es,ax
	mov	bx,OffsetOfKernelFile
	mov	ax,cx

LABEL_GOON_LOADING_FILE:
	push	ax
	push	bx
	mov	ah,0Eh
	mov	al,'.'
	mov	bl,0Fh
	int	10h
	pop	bx
	pop	ax

	mov	cl,1
	call	ReadSector
	pop	ax
	call	GetFATEntry
	cmp	ax,0FFFh
	jz	LABEL_FILE_LOADED
	push	ax
	mov	dx,RootDirSectors
	add	ax,dx
	add	ax,DeltaSectorNo
	add	bx,[BPB_BytsPerSec]
	jmp	LABEL_COON_LOADING_FILE
LABEL_FILE_LOADED:
	
	call	KillMotor

	mov	dh,1
	call	DispStr

	jmp	$





;============================================================================
;变量
;----------------------------------------------------------------------------
wRootDirSizeForLoop	dw	RootDirSectors	; Root Directory 占用的扇区数
wSectorNo		dw	0		; 要读取的扇区号
bOdd			db	0		; 奇数还是偶数
dwKernelSize		dd	0		; KERNEL.BIN 文件大小

;============================================================================
;字符串
;----------------------------------------------------------------------------
KernelFileName		db	"KERNEL  BIN", 0	; KERNEL.BIN 之文件名
; 为简化代码, 下面每个字符串的长度均为 MessageLength
MessageLength		equ	9
LoadMessage:		db	"Loading  "
Message1		db	"Ready.   "
Message2		db	"No KERNEL"
;============================================================================

;----------------------------------------------------------------------------
; 函数名: DispStr
;----------------------------------------------------------------------------
; 作用:
;	显示一个字符串, 函数开始时 dh 中应该是字符串序号(0-based)
DispStr:
	mov	ax, MessageLength
	mul	dh
	add	ax, LoadMessage
	mov	bp, ax			; ┓
	mov	ax, ds			; ┣ ES:BP = 串地址
	mov	es, ax			; ┛
	mov	cx, MessageLength	; CX = 串长度
	mov	ax, 01301h		; AH = 13,  AL = 01h
	mov	bx, 0007h		; 页号为0(BH = 0) 黑底白字(BL = 07h)
	mov	dl, 0
	add	dh, 3			; 从第 3 行往下显示
	int	10h			; int 10h
	ret
;----------------------------------------------------------------------------
; 函数名: ReadSector
;----------------------------------------------------------------------------
; 作用:
;	从序号(Directory Entry 中的 Sector 号)为 ax 的的 Sector 开始, 将 cl 个 Sector 读入 es:bx 中
ReadSector:
	; -----------------------------------------------------------------------
	; 怎样由扇区号求扇区在磁盘中的位置 (扇区号 -> 柱面号, 起始扇区, 磁头号)
	; -----------------------------------------------------------------------
	; 设扇区号为 x
	;                           ┌ 柱面号 = y >> 1
	;       x           ┌ 商 y ┤
	; -------------- => ┤      └ 磁头号 = y & 1
	;  每磁道扇区数     │
	;                   └ 余 z => 起始扇区号 = z + 1
	push	bp
	mov	bp, sp
	sub	esp, 2			; 辟出两个字节的堆栈区域保存要读的扇区数: byte [bp-2]

	mov	byte [bp-2], cl
	push	bx			; 保存 bx
	mov	bl, [BPB_SecPerTrk]	; bl: 除数
	div	bl			; y 在 al 中, z 在 ah 中
	inc	ah			; z ++
	mov	cl, ah			; cl <- 起始扇区号
	mov	dh, al			; dh <- y
	shr	al, 1			; y >> 1 (其实是 y/BPB_NumHeads, 这里BPB_NumHeads=2)
	mov	ch, al			; ch <- 柱面号
	and	dh, 1			; dh & 1 = 磁头号
	pop	bx			; 恢复 bx
	; 至此, "柱面号, 起始扇区, 磁头号" 全部得到 ^^^^^^^^^^^^^^^^^^^^^^^^
	mov	dl, [BS_DrvNum]		; 驱动器号 (0 表示 A 盘)
.GoOnReading:
	mov	ah, 2			; 读
	mov	al, byte [bp-2]		; 读 al 个扇区
	int	13h
	jc	.GoOnReading		; 如果读取错误 CF 会被置为 1, 这时就不停地读, 直到正确为止

	add	esp, 2
	pop	bp

	ret

;----------------------------------------------------------------------------
; 函数名: GetFATEntry
;----------------------------------------------------------------------------
; 作用:
;	找到序号为 ax 的 Sector 在 FAT 中的条目, 结果放在 ax 中
;	需要注意的是, 中间需要读 FAT 的扇区到 es:bx 处, 所以函数一开始保存了 es 和 bx
GetFATEntry:
	push	es
	push	bx
	push	ax
	mov	ax, BaseOfKernelFile	; ┓
	sub	ax, 0100h		; ┣ 在 BaseOfKernelFile 后面留出 4K 空间用于存放 FAT
	mov	es, ax			; ┛
	pop	ax
	mov	byte [bOdd], 0
	mov	bx, 3
	mul	bx			; dx:ax = ax * 3
	mov	bx, 2
	div	bx			; dx:ax / 2  ==>  ax <- 商, dx <- 余数
	cmp	dx, 0
	jz	LABEL_EVEN
	mov	byte [bOdd], 1
LABEL_EVEN:;偶数
	xor	dx, dx			; 现在 ax 中是 FATEntry 在 FAT 中的偏移量. 下面来计算 FATEntry 在哪个扇区中(FAT占用不止一个扇区)
	mov	bx, [BPB_BytsPerSec]
	div	bx			; dx:ax / BPB_BytsPerSec  ==>	ax <- 商   (FATEntry 所在的扇区相对于 FAT 来说的扇区号)
					;				dx <- 余数 (FATEntry 在扇区内的偏移)。
	push	dx
	mov	bx, 0			; bx <- 0	于是, es:bx = (BaseOfKernelFile - 100):00 = (BaseOfKernelFile - 100) * 10h
	add	ax, SectorNoOfFAT1	; 此句执行之后的 ax 就是 FATEntry 所在的扇区号
	mov	cl, 2
	call	ReadSector		; 读取 FATEntry 所在的扇区, 一次读两个, 避免在边界发生错误, 因为一个 FATEntry 可能跨越两个扇区
	pop	dx
	add	bx, dx
	mov	ax, [es:bx]
	cmp	byte [bOdd], 1
	jnz	LABEL_EVEN_2
	shr	ax, 4
LABEL_EVEN_2:
	and	ax, 0FFFh

LABEL_GET_FAT_ENRY_OK:

	pop	bx
	pop	es
	ret
;----------------------------------------------------------------------------





KillMotor:
	push	dx
	mov	dx,03F2h
	mov	al,0
	out	dx,al
	pop	dx
	ret