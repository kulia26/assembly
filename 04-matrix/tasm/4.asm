include init.asm

stseg segment para stack 'stack'
	db 64 dup ('stack')
stseg ends

dseg segment para public 'data'
	array                  dw 2 dup (3 dup ('LH')); [i][j], i - �������, j - �������
	array_h                db 2d; ���������� �������
	array_l                db 3d; ����� �������
	element                dw '$$'
	
	el_i                   db 'i = $'
	el_j                   db ' j = $'
	not_found_s			   db 'not found$'
	
	not_print              dw 0
	number                 dw 0
	mult10                 dw 1d
	div10                  dw 10000d
	
	buffer                 db 7, 'N', 7 dup('$'); buffer '6??????'+endline
	string 				   db 7 dup ('$'), '$$'
	
	
	s_invalid              db 'error: not in -32736..32767 range$'
	s_invalid_z            db 'error: sum not in -32736..32767 range$'
	s_incorrect_err        db 'error: incorrect symbol$'
	s_overflow             db 'overflow: sum not in -32736..32767 range$'
	
	enter_find             db 'What your looking for ?: $'
	enter_start            db 'Enter element i = '
	i                      db 0d
	enter_middle           db ' j = '
	j                      db 0d
	enter_end              db ' -32736..32767 (press e to ex): ', '$'
	
	array_begin            db '[', '$'
	array_end              db ']', '$'
	separator              db ', ', '$'

	endline                db 13d,10d,'$'   ;"\cr"
	
dseg ends

cseg segment para public 'code'
	main proc far
		init cseg, dseg, stseg
		program_loop:
		xor cx, cx; ������ �������
		mov cl, 0d; ������� � 0
		
			call push_to_array
				jcxz exit;
				jo program_loop;
			call read_element;
				jcxz exit;
				jo program_loop;
			call write_array
			call find;
				jcxz exit;
				jo program_loop;

			exit:
				ret
	main endp
	
	write_array proc near
		xor cx, cx
		write_row_loop:
		call writeEndline
			mov ch, 0d;
			lea dx, array_begin; ; write element
				call write
			
			write_col_loop:	
				
				mov i, cl;
				mov j, ch;
				
				xor ax, ax;
				xor bx, bx;
				xor dx, dx;
				
				mov bh, 2;
				mov al, i;
				mul bh;
				mov bl, array_l;
				mul bl;
				xor bx, bx;
				mov bx, ax; 2*4*i
				
				xor ax, ax;
				mov dh, 2;
				mov al, j;
				mul dh; ax = 2*j
				add bx, ax;
				
				mov ax, array[bx]
				mov number, ax;
				call itoa;
				
				
				lea dx, string; ; write element
				call write
				
		
				inc ch
				cmp ch, array_l
					jne write_sep; ���������
			lea dx, array_end; ; write element
				call write
			inc cl
			cmp cl, array_h
				jne write_row_loop; ���������
			mov cx, 1d ; ����� �� ����� �� jcxz
		ret
		
			write_sep:
			lea dx, separator; ; write element
				call write
			jmp write_col_loop
	write_array endp
	
	find proc near
		xor cx, cx;
		xor di, di;
		find_row_loop:
			mov ch, 0d;
			find_col_loop:	
				
				mov i, cl;
				mov j, ch;
				
				xor ax, ax;
				xor bx, bx;
				xor dx, dx;
				
				mov bh, 2;
				mov al, i;
				mul bh;
				mov bl, array_l;
				mul bl;
				xor bx, bx;
				mov bx, ax; 2*4*i
				
				xor ax, ax;
				mov dh, 2;
				mov al, j;
				mul dh; ax = 2*j
				add bx, ax;
				
				mov ax, array[bx]
				
				cmp element, ax
					je write_index
				continue:
				inc ch
				cmp ch, array_l
					jne find_col_loop; ���������
				jmp continue_1
				write_index:
				inc di;
				xor ax, ax;
				mov al, i;
				mov number, ax;
				call itoa; ������� ����� ����� ������ ��� ���
				call writeEndline;������ ������
				lea dx, el_i; ; write element
				call write
				lea dx, string; ; write element
				call write
				
				xor ax, ax;
				mov al, j;
				mov number, ax;
				call itoa; ������� ����� ����� ������ ��� ���
				lea dx, el_j; ; write element
				call write
				lea dx, string; ; write element
				call write
				
				jmp continue
			continue_1:
			inc cl
			cmp cl, array_h
				jne find_row_loop; ���������
			mov cx, 1d ; ����� �� ����� �� jcxz
			cmp di, 0d;
				je not_found;
		ret
			f_make_exit:
			mov cx, 0;
			ret
			f_make_overflow:
			mov cx, 0ffffh;
			mov cx, 0ffffh;
			ret
			not_found:
			call writeEndline;������ ������
			lea dx, not_found_s; ; write element
			call write
			ret
	find endp
	
	push_to_array proc near
		xor cx, cx;
		push_row_loop:
			mov ch, 0d;
			push_col_loop:
				; ����� = ������ + 2*(������_����*�����_������ + ������_������)
				; index = 2 * ( 4 * i + j )
				; cl = i = array_h
				; ch = j = array_l
				
				call writeEndline;������ ������
				add cl, '0'; c ������� i ������ ������-�����
				add ch, '0'; c ������� j ������ ������-����� 
				mov i, cl;
				mov j, ch;
				lea dx, enter_start; ; write "Enter i = "
					call write
				sub cl, '0'; ���������� ������ i � ���������� ���������
				sub ch, '0'; ���������� ������ j � ���������� ���������
				mov i, cl;
				mov j, ch;

				call read
				cmp buffer + 1, 0d; ���� ������ �� ����� �� �����
					je make_exit;
				
				call atoi
					jo make_overflow
				
				xor ax, ax;
				xor bx, bx;
				xor dx, dx;
				
				mov bh, 2;
				mov al, i;
				mul bh;
				mov bl, array_l;
				mul bl;
				xor bx, bx;
				mov bx, ax; 2*4*i
				
				xor ax, ax;
				mov dh, 2;
				mov al, j;
				mul dh; ax = 2*j
				add bx, ax;
				
				mov ax, number
				mov array[bx], ax;  
				
				call itoa; ������� ����� ����� ������ ��� ���
				call writeEndline;������ ������
				lea dx, string; ; write element
				call write
				
				inc ch
				cmp ch, array_l
					jne push_col_loop; ���������
			inc cl
			cmp cl, array_h
				jne push_row_loop; ���������
			
				
			
			mov cx, 1d ; ����� �� ����� �� jcxz
		ret
			make_exit:
			mov cx, 0;
			ret
			make_overflow:
			mov cx, 0ffffh;
			mov cx, 0ffffh;
			ret
	push_to_array endp
	
	read_element proc near
		xor cx, cx;
		call writeEndline;������ ������
		add cl, '0'; c ������� i ������ ������-�����
		add ch, '0'; c ������� j ������ ������-����� 
		lea dx, enter_find; ; write "Enter i = "
		call write
		call read
		cmp buffer + 1, 0d; ���� ������ �� ����� �� �����
			je r_make_exit;
		call atoi
			jo r_make_overflow
		mov ax, number
		mov element, ax;  
		ret
		r_make_exit:
		mov cx, 0;
		ret
		r_make_overflow:
		mov cx, 0ffffh;
		mov cx, 0ffffh;
		ret
	read_element endp
	
	atoi proc near
		push cx;
		push si;
		mov mult10, 1d ; ������ ������� �������� (1, 10, 100,...)
		mov number, 0d ; ������ ���������� � �����������
		xor bx, bx; ������
		xor ax, ax; ������
		xor si, si; ������
		mov cx, 10d ; ���������
		lea di, number; � di ����� ���� ������ ���������
		mov al, 45d; ���� ������
		lea si, buffer
		inc si; ������ ������ - 1 ����������
		mov bl, [si]; ���������� ��������� � �������
		cmp [si + 1], al; ���� ����� ������� ���� �������������
			je minus; �������
		
		cmp bl, 5d
			jo error_invalid;
		do:
			xor ax, ax; ������
			xor dx, dx; ������
			mov al, [si + bx]; ������ � al �������, ���� � �����
			sub al, '0'; � ������� ASCII �������� �����
			cmp al, 9d; ���� ����� ������ 9 �� ��� �� �����
				ja error_incorrect
			imul mult10; ������ ����� �� ������ (1,10,100,... ) ������������� dx !
				js error_invalid;
			cmp dx, 0000h
				jne error_invalid;
				jo error_invalid;
			add [di], ax; ��������� ���������
				jo error_invalid;���� �������� ������ ��� 32767 �� ������
				js error_invalid;���� �������� �������������� ������ ��� �����
			mov ax, mult10; ������ � ax ������� ���������
			cmp ax, 10000d
				je next
			mul cx; ����������� ��������� � 10 ���
			mov mult10, ax; ������ ������� � ����������
			next:
			dec bl; ��������� �������
				jnz do; ���������, ���� ������� �� ����� 0
			mov al, 45d;
			cmp [si], al; ���� ����� ������� ����� �� �������
				jz neg_number;
			pop si
			pop cx
			
		ret 
		neg_number:
			cmp [di], 7fe0h; ���� ����� � ������� � �� ������ > 32736, �� ������
				ja error_invalid;
			mov ax, number ; ��������
			neg ax ; ������ �������������� �� ��������������
			mov number, ax; ������ �������
			pop si
			pop cx
			
			ret
		error_invalid:	
			call writeEndline;
			lea dx, s_invalid; ; write "error invalid"
			call write;
			call writeEndline;
			jmp makeOF
		error_incorrect:
			call writeEndline;
			lea dx, s_incorrect_err; ; write "error invalid"
			call write;
			jmp makeOF
		minus:
			; ���� ������� ���������� ���� ����� �������, ��������� �����, � ����������
			inc si; ���������� ��������� � �������
			sub bl, 1h; ��������� ����������, ������ ��� ���� �� ������ ��� "-"
			jmp do;
		makeOF:
			pop si
			pop cx
			add ax, 30000d;
			add ax, 30000d;
			ret
	atoi endp

	itoa proc near
		push cx
		push di
		xor cx, cx
		xor di, di
		lea di, string;
		mov cx, 5d;
		mov bx, 10d;
		mov not_print, 0;
		cmp number, 0h;����� ������ ����?
			jl add_minus;���� ������ ���� �� ������� 
		cmp number, 0h;����� ������ ����?
			je null;���� ���� �� ������� ����
		make:;�������� ������ � ������������� ������, ����� ��� ��������
			mov ax, number;
			cmp ax, 0h;
				je zero;
			xor dx, dx;
			div div10; ����� �� 10 000, 1000, 100, ...
			mov number, dx;	������ ������� ��� ����� �����
			cmp ax, 0;
				jne set_not_print;
			start:
			add ax, '0';������ �� �����  ->> ascii
			xor dx, dx;
			cmp not_print, 0d
				je print2
			print:
			mov [di], ax; ������ � ������
				jmp the_end
			print2:
			dec di
			the_end:
			xor dx, dx;
			mov ax, div10; //
			div bx;        // ��������� ������-�������� � 10 ���
			mov div10, ax; //
			inc di; ��������� �� ��������� ����� � ������
			dec cx; ��������� �������
				jnz make; ������� ���� ������� �� ����� ����
				jmp itoa_exit;
		add_minus:
			xor ax, ax;
			mov al, 2dh;
			mov [di], ax;������� ����� � ������
			inc di ������ �� ������ �����
			neg number; ������� ������������� ������������� 
			jmp make; �������
		zero:
			mov ax, '0'
			mov [di], ax;
			inc di;
			dec cx;
			jnz zero
			jmp itoa_exit
		itoa_exit:
			mov ax, '$'
			mov [di], ax;
			mov div10, 10000d;
			pop di
			pop cx
			ret
		set_not_print:
			mov not_print, 1d;
			jmp start;
		null:
			mov ax, '0'
			mov [di], ax;
			inc di;
			dec cx;
			jmp itoa_exit
	itoa endp
	
	read proc near
		lea dx, buffer
		mov ah, 10
		int 21h
		ret
	read endp
	
	
	write proc near
		mov ah, 9
		int 21h
		ret
	write endp
	
	writeEndline proc near
		lea dx, endline
		mov ah, 9
		int 21h
		ret
	writeEndline endp
cseg ends
end main
