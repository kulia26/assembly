stseg segment para stack 'stack'
	db 64 dup ('stack')
stseg ends

dseg segment para public 'data' 
	sum                    dw 0h
	array                  dw 10 dup (0h)
	array_size             db 10d
	max                    dw 0h
	min                    dw 0h
	
	not_print              dw 0
	number                 dw 0
	mult10                 dw 1d
	div10                  dw 10000d
	
	buffer                 db 7, 'N', 7 dup('$'), '$'; buffer '6??????'+endline
	
	enter_start            db 'Enter element i = '
	index                  db 7d
	enter_end              db ' -32736..32767 (press e to ex): ', '$'
	
	s_sum				   db 'sum = $'
	s_max				   db 'max = $'
	s_min				   db 'min = $'
	string 				   db 7 dup ('$')
	
	s_invalid              db 'error: not in -32736..32767 range$'
	s_invalid_z            db 'error: sum not in -32736..32767 range$'
	s_incorrect_err        db 'error: incorrect symbol$'
	s_overflow             db 'overflow: sum not in -32736..32767 range$'
	
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
		xor cx, cx; чистим счетчик
		mov cl, array_size; счетчик в размер массива (8)
		
			call push_to_array
				jcxz exit;
				jo program_loop;
				
			call reduce; считаем суму елементов
				jo program_loop
				
			call write_sum
			
			call find_max; считаем суму елементов
				
			call write_max
			
			call find_min; считаем суму елементов
			
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
	
	push_to_array proc near
		push_loop:
			dec cl; индекс последнего  = размер масива - 1
			mov si, cx; адрес = начало + (индекс*размерность)
			shl si, 1; * на 2, размер елемента 2 байта 
			call writeEndline;пустую строку

			add cl, '0'; c индекса делаем символ-цифру 
			mov index, cl;
			lea dx, enter_start; ; write "Enter i = "
				call write
			sub cl, '0'; возвращаем индекс в нормальное состоЯние

			call read
			cmp buffer + 1, 0d; если ничего не ввели то выйти
				je make_exit;
			
			call atoi
				jo make_overflow
				
			mov ax, number; add integer
			mov array[si], ax;  to array
			
			call itoa; выведем число чтобы понЯть что там
			call writeEndline;пустую строку
			lea dx, string; ; write element
			call write
			cmp cx, 0d
				jnz push_loop; повторЯем
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
		
		mov cl, array_size; счетчик в размер массива (8)
		r_loop:
		dec cl; индекс последнего  = размер масива - 1
		mov si, cx; адрес = начало + (индекс*размерность)
		shl si, 1; * на 2, размер елемента 2 байта 
		mov ax, array[si];  to array
		add bx, ax;
			jo reduce_overflow
		mov sum, bx; записываем суму
			cmp cl, 0d
			jnz r_loop; повторЯем если индекс не равен 0
		ret
		reduce_overflow:
			jmp overflow;
			ret
	reduce endp
	
	find_max proc near
		mov ax, array[0];  нехай перший максимальний
		mov max, ax;
		xor bx, bx;
		
		mov cl, array_size; счетчик в размер массива (8)
		fm_loop:
		dec cl; индекс последнего  = размер масива - 1
		mov si, cx; адрес = начало + (индекс*размерность)
		shl si, 1; * на 2, размер елемента 2 байта 
		mov ax, array[si];  ax - текущий елемент
		cmp max, ax
			jl change; если текщий максимум меньше елемента,
		cont:
			cmp cl, 0d
			jnz fm_loop; повторЯем если индекс не равен 0
		ret
		change:
			mov max, ax; теперь текущий максимум равен елементу
			jmp cont;
	find_max endp
	
	find_min proc near
		mov ax, array[0];  нехай перший максимальний
		mov min, ax;
		xor bx, bx;
		
		mov cl, array_size; счетчик в размер массива (8)
		fmin_loop:
		dec cl; индекс последнего  = размер масива - 1
		mov si, cx; адрес = начало + (индекс*размерность)
		shl si, 1; * на 2, размер елемента 2 байта 
		mov ax, array[si];  ax - текущий елемент
		cmp min, ax
			jg m_change; если текщий максимум меньше елемента,
		m_cont:
			cmp cl, 0d
			jnz fmin_loop; повторЯем если индекс не равен 0
		ret
		m_change:
			mov min, ax; теперь текущий максимум равен елементу
			jmp m_cont;
	find_min endp
	
	sort proc near
		sort_out_loop:
		xor bx, bx;
		xor cx, cx;
		mov cl, array_size; счетчик в размер массива (8)
		sort_loop:
		dec cl; индекс последнего  = размер масива - 1
		mov si, cx; адрес = начало + (индекс*размерность)
		shl si, 1; * на 2, размер елемента 2 байта 
		mov ax, array[si];  ax - текущий елемент
		mov bx, array[si - 2];  bx - следующий елемент
		cmp bx, ax; если ах ,больше бх
			jl shift; поменЯть местами
		sort_cont:
			cmp cl, 2d
			jae sort_loop; повторЯем если индекс больше 1
		ret
		shift:
			mov array[si], bx;
			mov array[si - 2], ax;
			jmp sort_out_loop;
	sort endp
	
	atoi proc near
		push cx;
		push si;
		mov mult10, 1d ; чистим счетчик разрЯдов (1, 10, 100,...)
		mov number, 0d ; чистим переменную с результатом
		xor bx, bx; чистим
		xor ax, ax; чистим
		mov cx, 10d ; множитель
		lea di, number; в di адрес куда ложить результат
		mov al, 45d; знак пробела
		lea si, buffer
		inc si; индекс начала - 1 показывает
		mov bl, [si]; количество елементов в буффере
		cmp [si + 1], al; если минус впереди надо подготовитьсЯ
			jz minus; пригаем
		
		cmp bl, 5d
			jo error_invalid;
		do:
			xor ax, ax; чистим
			xor dx, dx; чистим
			mov al, [si + bx]; кидаем в al елемент, идем с конца
			sub al, '0'; с символа ASCII получаем цифру
			cmp al, 9; если число больше 9 то это не число
				ja error_incorrect
			imul mult10; множим цифру на разрЯд (1,10,100,... ) испольхуетьсЯ dx !
				js error_invalid;
			cmp dx, 0000h
				jne error_invalid;
				jo error_invalid;
			add [di], ax; суммируем результат
				jo error_invalid;если значение больше чем 32767 то ошибка
				js error_invalid;если значение отритцательное значит все плохо
			mov ax, mult10; кидаем в ax текущий множитель
			mul cx; увеличиваем множитель в 10 раз
			mov mult10, ax; кидаем обратно в переменную
			dec bl; уменьшаем счетчик
				jnz do; повторЯем, если счетчик не равен 0
			mov al, 45d;
			cmp [si], al; если минус впереди числа то пригаем
				jz neg_number;
			pop si
			pop cx
			
		ret 
		neg_number:
			cmp [di], 7fe0h; если число с минусом а по модулю > 32736, то ошибка
				ja error_invalid;
			mov ax, number ; вынимаем
			neg ax ; делаем отритцательное из положительного
			mov number, ax; кидаем обратно
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
			; надо сделать подготовку если минус впереди, уменьшить длину, и количество
			inc si; количество елементов в буффере
			sub bl, 1h; уменьшаем количество, потому что один из знаков это "-"
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
		cmp number, 0h;число меньше нулЯ?
			jl add_minus;если меньше нулЯ то пригаем 
		cmp number, 0h;число меньше нулЯ?
			je null;если нуль то выводим нуль
		make:;работаем только с положительным числом, минус уже написали
			mov ax, number;
			cmp ax, 0h;
				je zero;
			xor dx, dx;
			div div10; делим на 10 000, 1000, 100, ...
			mov number, dx;	теперь остаток это новое число
			cmp ax, 0;
				jne set_not_print;
			start:
			add ax, '0';делаем из цифры  ->> ascii
			xor dx, dx;
			cmp not_print, 0d
				je print2
			print:
			mov [di], ax; кидаем в строку
				jmp the_end
			print2:
			dec di
			the_end:
			xor dx, dx;
			mov ax, div10; //
			div bx;        // уменьшаем разрЯд-делитель в 10 раз
			mov div10, ax; //
			inc di; двигаемсЯ на следующее место в строке
			dec cx; уменьшаем счетчик
				jnz make; прыгаем если счетчик не равен нулю
				jmp itoa_exit;
		add_minus:
			xor ax, ax;
			mov al, 2dh;
			mov [di], ax;добавим минус в переди
			lea di, string + 1; начало на первую цифру
			neg number; сделаем отрицательное положительным 
			jmp make; прыгнем
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
		mov cl, array_size; счетчик в размер массива (8)
		wa_loop:
		dec cl; индекс последнего  = размер масива - 1
		mov si, cx; адрес = начало + (индекс*размерность)
		shl si, 1; * на 2, размер елемента 2 байта 
		mov ax, array[si];  to array
		mov number, ax
		call itoa
		lea dx, string
		call write
		cmp cl, 0d
			jne wa_separator
		wa_end:
			cmp cl, 0d
			jnz wa_loop; повторЯем если индекс не равен 0
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
			call itoa; выведем суму
			call writeEndline;пустую строку
			lea dx, s_sum; ; write element
			call write
			lea dx, string; ; write element
			call write
			call writeEndline;пустую строку
			ret
	write_sum endp
	
	write_max proc near
		mov ax, max
			mov number, ax
			call itoa; выведем суму
			lea dx, s_max; ; write element
			call write
			lea dx, string; ; write element
			call write
			call writeEndline;пустую строку
			ret
	write_max endp
	
	write_min proc near
			mov ax, min
			mov number, ax
			call itoa; выведем суму
			;call writeEndline;пустую строку
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
