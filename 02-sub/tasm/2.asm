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
		mov mult10, 1d ; чистим счетчик разрядов (1, 10, 100,...)
		mov number, 0d ; чистим переменную с результатом
		xor bx, bx; чистим
		mov cx, 10d ; множитель
		xor si, si; чистим
		lea di, number; в di адрес куда ложить результат
		cmp buffer + 2, 45d; если минус впереди надо подготовиться
			jz minus; пригаем
		lea si, buffer + 1; индекс начала - 1 показывает
		mov bl, buffer + 1; количество елементов в буффере
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
			cmp buffer + 2, 45d; если минус впереди числа то пригаем
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
			lea dx, s_invalid_err; ; write "error invalid"
			call write;
			jmp makeOF
		error_incorrect:
			call writeEndline;
			lea dx, s_incorrect_err; ; write "error invalid"
			call write;
			jmp makeOF
		minus:
			; надо сделать подготовку если минус впереди, уменьшить длину, и количество
			lea si, buffer + 2; индекс начала - 1 показывает
			mov bl, buffer + 1; количество елементов в буффере
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
