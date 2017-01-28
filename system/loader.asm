org 0100h

	mov	ax,0b800h
	mov	gs,ax
	mov	ah,0Fh
	mov	al,'L'
	mov	[gs:((80*10+39)*2)],ax

	jmp	$