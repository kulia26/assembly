stseg segment para stack 'stack'
	db 64 dup ('stack')
stseg ends

dseg segment para public 'data' 
	z                      dw 0h
	x                      dw 0h
	y                      dw 0h
	ost                    dw 0h
	divisor                dw 0h
	
	not_print              dw 0
	number                 dw 0
	mult10                 dw 1d
	div10                  dw 10000d
	
	buffer_x               db 7, 'N', 7 dup('$'), '$'; buffer '6??????'+endline
	buffer                 db 7, 'N', 7 dup('$'), '$'; buffer '6??????'+endline
	buffer_y               db 7, 'N', 7 dup('$'), '$'; buffer '6??????'+endline
	
	enter_x                db 'Enter x -32767..32767 (press enter to exit): ', '$'
	enter_y                db 'Enter y -32767..32767 (press enter to exit): ', '$'

	string 				   db 7 dup ('$')
	s_invalid              db 'error: not in -32736..32767 range$'
	s_invalid_z            db 'error: Z not in -32736..32767 range$'
	s_incorrect_err        db 'error: incorrect symbol$'
	s_overflow             db 'overflow: Z not in -32736..32767 range$'
	plus_s                 db ' + $'
	div_s                  db '/$'
	
	endline                db 13d,10d,'$'   ;"\cr"
	
dseg ends

cseg segment para public 'code'
	main proc far
		assume cs: cseg, ds: dseg, ss: stseg
		push ds
		xor ax, ax
		push ax
		mov ax, dseg
		mov ds, ax
		program_loop:
			loop_x:
			call writeEndline;
			lea dx, enter_x; ; write "Enter x"
			call write
			
			call read_x
			cmp buffer_x + 1, 0;
				je exit;
			lea si, buffer_x
			call atoi
				jo loop_x
			mov ax, number
			mov x, ax
			call writeEndline;
			loop_y:
			call writeEndline;
			lea dx, enter_y; ; write "Enter y"
			call write
			
			call read_y
			cmp buffer_y + 1, 0;
				je exit;
			lea si, buffer_y
			call atoi
				jo loop_y
			mov ax, number
			mov y, ax
			
			call function
				jo program_loop
			mov ax, z
			mov number, ax
			call itoa;
			
			call writeEndline;
			lea dx, string; ; write "�����"
			call write
			
			cmp ost, 0;
				jnz write_ost
			
			jmp program_loop
			exit:
				ret
			write_ost:
				xor ax, ax;
				mov ax, ost
				mov number, ax
				call itoa
				lea dx, plus_s; ; write "�����"
				call write
				lea dx, string; ; write "�����"
				call write
				lea dx, div_s; ; write "�����"
				call write
				xor ax, ax
				mov ax, divisor;
				mov number, ax;
				call itoa;
				lea dx, string;
				call write
			jmp program_loop
	main endp
	
	atoi proc near
		mov mult10, 1d ; ������ ������� �������� (1, 10, 100,...)
		mov number, 0d ; ������ ���������� � �����������
		xor bx, bx; ������
		xor ax, ax; ������
		mov cx, 10d ; ���������
		lea di, number; � di ����� ���� ������ ���������
		mov al, 45d; ���� �������
		inc si; ������ ������ - 1 ����������
		mov bl, [si]; ���������� ��������� � �������
		cmp [si + 1], al; ���� ����� ������� ���� �������������
			jz minus; �������
		
		cmp bl, 5d
			jo error_invalid;
		do:
			xor ax, ax; ������
			xor dx, dx; ������
			mov al, [si + bx]; ������ � al �������, ���� � �����
			sub al, '0'; � ������� ASCII �������� �����
			cmp al, 9; ���� ����� ������ 9 �� ��� �� �����
				ja error_incorrect
			mul mult10; ������ ����� �� ������ (1,10,100,... ) ������������� dx !
			cmp dx, 0000h
				jne error_invalid;
			add [di], ax; ��������� ���������
				jo error_invalid;���� �������� ������ ��� 32767 �� ������
				js error_invalid;���� �������� �������������� ������ ��� �����
			mov ax, mult10; ������ � ax ������� ���������
			mul cx; ����������� ��������� � 10 ���
			mov mult10, ax; ������ ������� � ����������
			dec bl; ��������� �������
				jnz do; ���������, ���� ������� �� ����� 0
			mov al, 45d;
			cmp [si], al; ���� ����� ������� ����� �� �������
				jz neg_number;
		ret 
		neg_number:
			cmp [di], 8000h; ���� ����� � ������� � �� ������ > 32767, �� ������
				ja error_invalid;
			mov ax, number ; ��������
			neg ax ; ������ �������������� �� ��������������
			mov number, ax; ������ �������
			ret
		error_invalid:	
			call writeEndline;
			lea dx, s_invalid; ; write "error invalid"
			call write;
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
			add ax, 30000d;
			add ax, 30000d;
			ret
	atoi endp

	itoa proc near
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
			lea di, string + 1; ������ �� ������ �����
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
			ret
		set_not_print:
			mov not_print, 1d;
			jmp start;
			ret
		null:
			mov ax, '0'
			mov [di], ax;
			inc di;
			dec cx;
			jmp itoa_exit
	itoa endp

	function proc near
		mov z, 1d;
		mov ost, 0;
		mov divisor, 0;
		cmp x, 0000h
			jg function1 ; x > 0
		cmp x, 0000h
			jl function2 ; x < 0	
		ret
	function endp
	
	function1 proc near; x > 0
		cmp y, 0000h ; and y > 0
			jg f1_1
		cmp x, 10d ; and x > 10
			jg f1_2
		ret
		f1_1:;z = (x+y)/(xy)
			mov ax, x
			mul y
				js f1_o;overflow
				jo f1_o;overflow
			mov bx, x
			add bx, y
				jo f1_o;overflow
			mov cx, ax; cx = xy
			mov ax, bx; ax = x+y
			xor dx, dx;
			cmp cx, 127d
				ja f1_1_null
			div cl
			jmp f1_1_nnull
			f1_1_null:
			mov ost, ax;
			mov z, 0000h
			mov divisor, cx;
			ret
			f1_1_nnull:
			mov byte ptr z, al 
			mov byte ptr ost, ah;
			mov divisor, cx;
			ret
		f1_2:;z = 6x ? maybe... if y = 0
			cmp y, 0d
				je f1_3
			ret
		f1_3:;z = 6x
			mov ax, x
			mov cx, 6d
			xor dx, dx;
			mul cx
				js f1_o
			cmp dx, 0d
				jne f1_o
			mov z, ax
			ret
		f1_o:;overflow
			jmp overflow
			ret
	function1 endp
	
	function2 proc near ; x < 0 
		cmp y, 0000h ; y < 0
			jl f2_1; 
			ret
		f2_1:; z = 25y
			mov ax, y
			mov cx, 25d
			imul cx
				jo f2_o
			mov z, ax
		ret
		f2_o:
			jmp overflow
			ret
	function2 endp
	
	
	overflow proc near
		call writeEndline;
		lea dx, s_overflow
		mov ah, 9d
		int 21h
		add ax, 30000d;
		add ax, 30000d;
		ret
	overflow endp
	
	read_x proc near
		lea dx, buffer_x
		mov ah, 10
		int 21h
		ret
	read_x endp
	
	read_y proc near
		lea dx, buffer_y
		mov ah, 10
		int 21h
		ret
	read_y endp
	
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
