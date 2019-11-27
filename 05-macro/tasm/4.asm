include init.asm
include itoa_m.asm
include atoi_m.asm
include findofs.asm

stseg segment para stack 'stack'
	db 64 dup ('stack')
stseg ends

dseg segment para public 'data'
	array_h                equ 2d; количество строчек
	array_l                equ 2d; длина строчки
	array                  dw array_h dup (array_l dup ('LH')); [i][j], i - строчка, j - столбец
	
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
		xor cx, cx; чистим счетчик
		mov cl, 0d; счетчик в 0
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
				
				findofs cl, ch, array
				
				mov ax, array[bx]
				mov number, ax;
				call itoa;
				
				
				lea dx, string; ; write element
				call write
				
		
				inc ch
				cmp ch, array_l
					jne write_sep; повторяем
			lea dx, array_end; ; write element
				call write
			inc cl
			cmp cl, array_h
				jne write_row_loop; повторяем
			mov cx, 1d ; чтобы не выйти на jcxz
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
				
				findofs i, j, array
				
				mov ax, array[bx]
				
				cmp element, ax
					je write_index
				continue:
				inc ch
				cmp ch, array_l
					jne find_col_loop; повторяем
				jmp continue_1
				write_index:
				inc di;
				xor ax, ax;
				mov al, i;
				mov number, ax;
				call itoa; выведем число чтобы понять что там
				call writeEndline;пустую строку
				lea dx, el_i; ; write element
				call write
				lea dx, string; ; write element
				call write
				
				xor ax, ax;
				mov al, j;
				mov number, ax;
				call itoa; выведем число чтобы понять что там
				lea dx, el_j; ; write element
				call write
				lea dx, string; ; write element
				call write
				
				jmp continue
			continue_1:
			inc cl
			cmp cl, array_h
				jne find_row_loop; повторяем
			mov cx, 1d ; чтобы не выйти на jcxz
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
			call writeEndline;пустую строку
			lea dx, not_found_s; ; write element
			call write
			ret
	find endp
	
	push_to_array proc near
		xor cx, cx;
		push_row_loop:
			mov ch, 0d;
			push_col_loop:
				; адрес = начало + 2*(индекс_р€да*длину_строки + индекс_строки)
				; index = 2 * ( 4 * i + j )
				; cl = i = array_h
				; ch = j = array_l
				
				call writeEndline;пустую строку
				add cl, '0'; c индекса i делаем символ-цифру
				add ch, '0'; c индекса j делаем символ-цифру 
				mov i, cl;
				mov j, ch;
				lea dx, enter_start; ; write "Enter i = "
					call write
				sub cl, '0'; возвращаем индекс i в нормальное состо€ние
				sub ch, '0'; возвращаем индекс j в нормальное состо€ние
				

				call read
				cmp buffer + 1, 0d; если ничего не ввели то выйти
					je make_exit;
				lea si, buffer
				call atoi
					jo make_overflow
				
				findofs
				
				mov ax, number
				mov array[bx], ax;  
				
				call itoa; выведем число чтобы понять что там
				call writeEndline;пустую строку
				lea dx, string; ; write element
				call write
				
				inc ch
				cmp ch, array_l
					jne push_col_loop; повторяем
			inc cl
			cmp cl, array_h
				jne push_row_loop; повторяем
			mov cx, 1d ; чтобы не выйти на jcxz
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
		call writeEndline;пустую строку
		add cl, '0'; c индекса i делаем символ-цифру
		add ch, '0'; c индекса j делаем символ-цифру 
		lea dx, enter_find; ; write "Enter i = "
		call write
		call read
		cmp buffer + 1, 0d; если ничего не ввели то выйти
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
		atoi_m buffer
		ret
	atoi endp

	itoa proc near
		itoa_m number
		ret
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
