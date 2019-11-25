stseg segment para stack 'stack'
	db 64 dup ('stack')
stseg ends

dseg segment para public 'data' 
	z                      dw 0h
	x                      dw 0h
	y                      dw 0h
	
	not_print              dw 0
	number                 dw 0
	mult10                 dw 1d
	div10                  dw 10000d
	
	buffer_x               db 7, 'N', 7 dup('$'), '$'; buffer '6??????'+endline
	buffer                 db 7, 'N', 7 dup('$'), '$'; buffer '6??????'+endline
	buffer_y               db 7, 'N', 7 dup('$'), '$'; buffer '6??????'+endline
	
	enter_x                db 'Enter x -32736..32767 (press enter to exit): ', '$'
	enter_y                db 'Enter y -32736..32767 (press enter to exit): ', '$'

	string 				   db 7 dup ('$')
	s_invalid              db 'error: not in -32736..32767 range$'
	s_invalid_z            db 'error: Z not in -32736..32767 range$'
	s_incorrect_err        db 'error: incorrect symbol$'
	s_overflow             db 'overflow: Z not in -32736..32767 range$'

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
			lea dx, string; ; write "Enter x"
			call write
			
			jmp program_loop
			exit:
				ret
	main endp
	
	atoi proc near
		mov mult10, 1d ; чистим счетчик разрядов (1, 10, 100,...)
		mov number, 0d ; чистим переменную с результатом
		xor bx, bx; чистим
		xor ax, ax; чистим
		mov cx, 10d ; множитель
		lea di, number; в di адрес куда ложить результат
		mov al, 45d; знак пробела
		inc si; индекс начала - 1 показывает
		mov bl, [si]; количество елементов в буффере
		cmp [si + 1], al; если минус впереди надо подготовиться
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
			mul mult10; множим цифру на разряд (1,10,100,... ) испольхуеться dx !
			cmp dx, 0000h
				jnz error_invalid;
			add [di], ax; суммируем результат
				jo error_invalid;если значение больше чем 32767 то ошибка
				js error_invalid;если значение отритцательное значит все плохо
			mov ax, mult10; кидаем в ax текущий множитель
			mul cx; увеличиваем множитель в 10 раз
			mov mult10, ax; кидаем обратно в переменную
			dec bl; уменьшаем счетчик
				jnz do; повторяем, если счетчик не равен 0
			mov al, 45d;
			cmp [si], al; если минус впереди числа то пригаем
				jz neg_number;
		ret 
		neg_number:
			cmp [di], 7fe0h; если число с минусом а по модулю > 32736, то ошибка
				ja error_invalid;
			mov ax, number ; вынимаем
			neg ax ; делаем отритцательное из положительного
			mov number, ax; кидаем обратно
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
			add ax, 30000d;
			add ax, 30000d;
			ret
	atoi endp

	itoa proc near
		lea di, string;
		mov cx, 5d;
		mov bx, 10d;
		mov not_print, 0;
		cmp number, 0h;число меньше нуля?
			jl add_minus;если меньше нуля то пригаем 
		cmp number, 0h;число меньше нуля?
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
			div bx;        // уменьшаем разряд-делитель в 10 раз
			mov div10, ax; //
			inc di; двигаемся на следующее место в строке
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
		cmp x, 0000h
			jg function1 ; x > 0
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
			mov cx, ax
			mov ax, bx
			div cx
			mov z, ax
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
