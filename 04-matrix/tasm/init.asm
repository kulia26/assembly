init macro cseg, dseg, stseg
	assume cs: cseg, ds: dseg, ss: stseg
	push ds
	xor ax, ax
	push ax
	mov ax, dseg
	mov ds, ax
endm