findofs macro
				mov i, cl;
				mov j, ch;
				
				xor ax, ax;
				xor bx, bx;
				xor dx, dx;
				
				mov bh, type array;2-for word, 1- for byte
				mov al, i;
				mul bh;
				mov bl, array_l;
				mul bl;
				xor bx, bx;
				mov bx, ax; 2*4*i
				
				xor ax, ax;
				mov dh, type array;
				mov al, j;
				mul dh; ax = 2*j
				add bx, ax;
endm