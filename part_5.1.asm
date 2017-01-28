[section .data]

strHello	db	"Hello, world!",0Ah
StrLen	equ	$-StrHello
[section .text]

global	_start

_start:
	mov	edx,StrLen
	mov	ecx,StrHello
	mov	ebx,1
	mov	eax,4
	int	0x80
	mov	ebx,0
	mov	eax,1
	int 0x80