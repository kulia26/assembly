stseg segment para stack 'stack'
	db 64 dup ('stack')
stseg ends

dseg segment para public 'data' 
	number                 dw 0h
	s_enter_num            db 'Enter number -32736..32767 (press enter to exit): ', '$'
	task                   db '  -32 =$'		
	string 				   db 7 dup (' ')
	s_invalid_err          db 'error: number not in -32736..32767 range$'
	s_incorrect_err        db 'error: incorrect symbol$'

	endline                db 13d,10d,'$'   ;"\cr"
	buffer                 db 7, 'N', 7 dup('$'), '$'; buffer '6??????'+endline
	
	not_print              dw 1
	mult10                 dw 1d
	div10                  dw 10000d
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
			call writeEndline;
			lea dx, s_enter_num; ; write "Enter number..."
			call write
			call read
			cmp buffer + 1, 0;
				je exit;
			call atoi;
				jo program_loop;
			mov ax, number	
			sub ax, 32
			mov number, ax
			call writeEndline
			call itoa;
			lea dx, task;
			call write;
			call writeEndline
			lea dx, string;
			call write;
			jmp program_loop
			exit:
				ret
	main endp
	
	atoi proc near
		mov mult10, 1d ; ������ ������� �������� (1, 10, 100,...)
		mov number, 0d ; ������ ���������� � �����������
		xor bx, bx; ������
		mov cx, 10d ; ���������
		xor si, si; ������
		lea di, number; � di ����� ���� ������ ���������
		cmp buffer + 2, 45d; ���� ����� ������� ���� �������������
			jz minus; �������
		lea si, buffer + 1; ������ ������ - 1 ����������
		mov bl, buffer + 1; ���������� ��������� � �������
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
				jnz error_invalid;
			add [di], ax; ��������� ���������
				jo error_invalid;���� �������� ������ ��� 32767 �� ������
				js error_invalid;���� �������� �������������� ������ ��� �����
			mov ax, mult10; ������ � ax ������� ���������
			mul cx; ����������� ��������� � 10 ���
			mov mult10, ax; ������ ������� � ����������
			dec bl; ��������� �������
				jnz do; ���������, ���� ������� �� ����� 0
			cmp buffer + 2, 45d; ���� ����� ������� ����� �� �������
				jz neg_number;
		ret 
		neg_number:
			cmp [di], 7fe0h; ���� ����� � ������� � �� ������ > 32736, �� ������
				ja error_invalid;
			mov ax, number ; ��������
			neg ax ; ������ �������������� �� ��������������
			mov number, ax; ������ �������
			ret
		error_invalid:	
			call writeEndline;
			lea dx, s_invalid_err; ; write "error invalid"
			call write;
			jmp makeOF
		error_incorrect:
			call writeEndline;
			lea dx, s_incorrect_err; ; write "error invalid"
			call write;
			jmp makeOF
		minus:
			; ���� ������� ���������� ���� ����� �������, ��������� �����, � ����������
			lea si, buffer + 2; ������ ������ - 1 ����������
			mov bl, buffer + 1; ���������� ��������� � �������
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
