stseg segment para stack 'stack'
	db 64 dup ('stack')
stseg ends

dseg segment para public 'data' 
	sum                    dw 0h
	array                  dw 20 dup ('LH')
	array_size             dw 0
	max                    dw 0h
	min                    dw 0h
	
	not_print              dw 0
	number                 dw 0
	mult10                 dw 1d
	div10                  dw 10000d
	
	buffer                 db 7, 'N', 7 dup('$'), '$'; buffer '6??????'+endline
	
	
	enter_size             db 'Enter array size (1..20) : $'
	enter_start            db 'Enter element i = $'
	enter_end              db ' -32736..32767 (press e to ex): ', '$'
	
	s_sum				   db 'sum = $'
	s_max				   db 'max = $'
	s_min				   db 'min = $'
	string 				   db 7 dup ('$')
	
	s_invalid              db 'error: not in -32767..32767 range$'
	s_invalid_z            db 'error: sum not in -32767..32767 range$'
	s_incorrect_err        db 'error: incorrect symbol$'
	s_overflow             db 'overflow: sum not in -32736..32767 range$'
	s_size_of              db 'array size not in range 1..20$'
	
	array_begin            db '[', '$'
	array_end              db ']', '$'
	separator              db ', ', '$'
	your_array             db 'array: ', '$'
	your_array_sorted      db 'sorted: ', '$'

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
			call push_size;
				jcxz exit
				jo program_loop;
			call push_to_array
				jcxz exit;
				jo program_loop;
				
			call reduce; ������� ���� ���������
				jo program_loop
				
			call write_sum
			
			call find_max; ������� ���� ���������
				
			call write_max
			
			call find_min; ������� ���� ���������
			
			call write_min
			
			call writeEndline
			lea dx, your_array; ; write [ 
			call write
			
			call write_array
			
			call sort;
			
			call writeEndline
			lea dx, your_array_sorted; ; write [ 
			call write
			
			call write_array
			exit:
				ret
	main endp
	
	push_size proc near
		xor cx, cx; ������ �������
		call writeEndline
		lea dx, enter_size; ; write [ 
			call write
		call read
		cmp buffer + 1, 0d; ���� ������ �� ����� �� �����
			je ps_exit;
		call atoi
			cmp number, 20d
			ja ps_of;
			cmp number, 1
			jl ps_of;
		mov cx, number; ������� � ������ ������� (8)
		mov array_size, cx;
		mov cx, 1d;
		ret
		ps_exit:
			mov cx, 0d
			ret
		ps_of:
			call writeEndline;
			lea dx, s_size_of
			mov ah, 9d
			int 21h
			add ax, 30000d;
			add ax, 30000d;
			mov cx, 1
			ret
	push_size endp 
	
	push_to_array proc near
		mov cx, array_size;
		push_loop:
			
			dec cx; ������ ����������  = ������ ������ - 1
			mov si, cx; ����� = ������ + (������*�����������)
			shl si, 1; * �� 2, ������ �������� 2 ����� 
			call writeEndline;������ ������
			mov number, cx
			call itoa
			lea dx, enter_start; ; write "Enter i = "
				call write
			lea dx, string; ; write "Enter i = "
				call write
			lea dx, enter_end; ; write "Enter i = "
				call write
			call read
			cmp buffer + 1, 0d; ���� ������ �� ����� �� �����
				je make_exit;
			
			call atoi
				jo make_overflow
				
			mov ax, number; add integer
			mov array[si], ax;  to array
			
			call itoa; ������� ����� ����� ������ ��� ���
			call writeEndline;������ ������
			lea dx, string; ; write element
			call write
			cmp cx, 0d
				jne push_loop; ���������
			mov cx, 1d;
		ret
			make_exit:
			mov cx, 0;
			ret
			make_overflow:
			mov cx, 0ffffh;
			mov cx, 0ffffh;
			ret
	push_to_array endp
	
	reduce proc near
		mov sum, 0d
		xor bx, bx;
		
		mov cx, array_size; ������� � ������ ������� (8)
		r_loop:
		dec cx; ������ ����������  = ������ ������ - 1
		mov si, cx; ����� = ������ + (������*�����������)
		shl si, 1; * �� 2, ������ �������� 2 ����� 
		mov ax, array[si];  to array
		add bx, ax;
			jo reduce_overflow
		mov sum, bx; ���������� ����
			cmp cx, 0d
			jnz r_loop; ��������� ���� ������ �� ����� 0
		ret
		reduce_overflow:
			jmp overflow;
			ret
	reduce endp
	
	find_max proc near
		mov ax, array[0];  ����� ������ ������������
		mov max, ax;
		xor bx, bx;
		
		mov cx, array_size; ������� � ������ ������� (8)
		fm_loop:
		dec cx; ������ ����������  = ������ ������ - 1
		mov si, cx; ����� = ������ + (������*�����������)
		shl si, 1; * �� 2, ������ �������� 2 ����� 
		mov ax, array[si];  ax - ������� �������
		cmp max, ax
			jl change; ���� ������ �������� ������ ��������,
		cont:
			cmp cx, 0d
			jnz fm_loop; ��������� ���� ������ �� ����� 0
		ret
		change:
			mov max, ax; ������ ������� �������� ����� ��������
			jmp cont;
	find_max endp
	
	find_min proc near
		mov ax, array[0];  ����� ������ ������������
		mov min, ax;
		xor bx, bx;
		
		mov cx, array_size; ������� � ������ ������� (8)
		fmin_loop:
		dec cx; ������ ����������  = ������ ������ - 1
		mov si, cx; ����� = ������ + (������*�����������)
		shl si, 1; * �� 2, ������ �������� 2 ����� 
		mov ax, array[si];  ax - ������� �������
		cmp min, ax
			jg m_change; ���� ������ �������� ������ ��������,
		m_cont:
			cmp cx, 0d
			jnz fmin_loop; ��������� ���� ������ �� ����� 0
		ret
		m_change:
			mov min, ax; ������ ������� �������� ����� ��������
			jmp m_cont;
	find_min endp
	
	sort proc near
		sort_out_loop:
		xor bx, bx;
		xor cx, cx;
		mov cx, array_size; ������� � ������ ������� (8)
		sort_loop:
		dec cx; ������ ����������  = ������ ������ - 1
		mov si, cx; ����� = ������ + (������*�����������)
		shl si, 1; * �� 2, ������ �������� 2 ����� 
		mov ax, array[si];  ax - ������� �������
		mov bx, array[si - 2];  bx - ��������� �������
		cmp bx, ax; ���� �� ,������ ��
			jl shift; �������� �������
		sort_cont:
			cmp cx, 1h
			ja sort_loop; ��������� ���� ������ ������ 1
		ret
		shift:
			mov array[si], bx;
			mov array[si - 2], ax;
			jmp sort_out_loop;
	sort endp
	
	atoi proc near
		push cx;
		push si;
		mov mult10, 1d ; ������ ������� �������� (1, 10, 100,...)
		mov number, 0d ; ������ ���������� � �����������
		xor bx, bx; ������
		xor ax, ax; ������
		mov cx, 10d ; ���������
		lea di, number; � di ����� ���� ������ ���������
		mov al, 45d; ���� �������
		lea si, buffer
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
			imul mult10; ������ ����� �� ������ (1,10,100,... ) ������������� dx !
				js error_invalid;
			cmp dx, 0000h
				jne error_invalid;
				jo error_invalid;
			add [di], ax; ��������� ���������
				jo error_invalid;���� �������� ������ ��� 32767 �� ������
			mov ax, mult10; ������ � ax ������� ���������
			mul cx; ����������� ��������� � 10 ���
			mov mult10, ax; ������ ������� � ����������
			dec bl; ��������� �������
				jnz do; ���������, ���� ������� �� ����� 0
			mov al, 45d;
			cmp [si], al; ���� ����� ������� ����� �� �������
				je neg_number;
			pop si
			pop cx
			
		ret 
		neg_number:
			cmp [di], 8000h; ���� ����� � ������� � �� ������ > 32768, �� ������
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

	overflow proc near
		call writeEndline;
		lea dx, s_overflow
		mov ah, 9d
		int 21h
		add ax, 30000d;
		add ax, 30000d;
		ret
	overflow endp
	
	read proc near
		lea dx, buffer
		mov ah, 10
		int 21h
		ret
	read endp
	
	write_array proc near
		
		lea dx, array_begin; ; write [ 
			call write
		
		xor bx, bx;
		mov cx, array_size; ������� � ������ ������� (8)
		wa_loop:
		dec cx; ������ ����������  = ������ ������ - 1
		mov si, cx; ����� = ������ + (������*�����������)
		shl si, 1; * �� 2, ������ �������� 2 ����� 
		mov ax, array[si];  to array
		mov number, ax
		call itoa
		lea dx, string
		call write
		cmp cx, 0d
			jne wa_separator
		wa_end:
			cmp cx, 0d
			jnz wa_loop; ��������� ���� ������ �� ����� 0
		lea dx, array_end; ; write [ 
			call write
		;call writeEndline
		ret
		wa_separator:
		lea dx, separator
		call write
		jmp wa_end
	write_array endp
	
	write proc near
		mov ah, 9
		int 21h
		ret
	write endp
	
	write_sum proc near
		mov ax, sum
			mov number, ax
			call itoa; ������� ����
			call writeEndline;������ ������
			lea dx, s_sum; ; write element
			call write
			lea dx, string; ; write element
			call write
			call writeEndline;������ ������
			ret
	write_sum endp
	
	write_max proc near
		mov ax, max
			mov number, ax
			call itoa; ������� ����
			lea dx, s_max; ; write element
			call write
			lea dx, string; ; write element
			call write
			call writeEndline;������ ������
			ret
	write_max endp
	
	write_min proc near
			mov ax, min
			mov number, ax
			call itoa; ������� ����
			;call writeEndline;������ ������
			lea dx, s_min; ; write element
			call write
			lea dx, string; ; write element
			call write
			ret
	write_min endp
	
	writeEndline proc near
		lea dx, endline
		mov ah, 9
		int 21h
		ret
	writeEndline endp
cseg ends
end main
