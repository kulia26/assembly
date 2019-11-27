func macro x, y
local exit
		mov z, 1d;
		cmp x, 0000h
			jg function1 ; x > 0
			jl function2 ; x < 0	
		jmp exit
		function1:; x > 0
		cmp y, 0000h ; and y > 0
			jg f1_1
		cmp x, 10d ; and x > 10
			jg f1_2
		jmp exit
		f1_1:;z = (x+y)/(xy)
			mov ax, x
			mul y
				js f1_o;overflow
				jo f1_o;overflow
			mov bx, x
			add bx, y
				jo f1_o;overflow
			mov cx, ax
			mov ax, bx
			div cx
			mov z, ax
			jmp exit
		f1_2:;z = 6x ? maybe... if y = 0
			cmp y, 0d
				je f1_3
			jmp exit
		f1_3:;z = 6x
			mov ax, x
			mov cx, 6d
			xor dx, dx;
			mul cx
				js f1_o
			cmp dx, 0d
				jne f1_o
			mov z, ax
			jmp exit
		f1_o:;overflow
			jmp overflow
			jmp exit
		function2:; x < 0 
		cmp y, 0000h ; y < 0
			jl f2_1; 
			jmp exit
		f2_1:; z = 25y
			mov ax, y
			mov cx, 25d
			imul cx
				jo f2_o
			mov z, ax
			jmp exit
		f2_o:
			jmp overflow
		exit:
			exitm
endm