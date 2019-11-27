atoi_m macro buffer
local minus, do, neg_number, error_invalid, error_incorrect
		push cx;
		push si;
		mov mult10, 1d ; чистим счетчик разрядов (1, 10, 100,...)
		mov number, 0d ; чистим переменную с результатом
		xor bx, bx; чистим
		xor ax, ax; чистим
		xor si, si; чистим
		mov cx, 10d ; множитель
		lea di, number; в di адрес куда ложить результат
		mov al, 45d; знак минуса
		lea si, buffer
		inc si; индекс начала - 1 показывает
		mov bl, [si]; количество елементов в буффере
		cmp [si + 1], al; если минус впереди надо подготовитьсЯ
			je minus; пригаем
		
		cmp bl, 5d
			jo error_invalid;
		do:
			xor ax, ax; чистим
			xor dx, dx; чистим
			mov al, [si + bx]; кидаем в al елемент, идем с конца
			sub al, '0'; с символа ASCII получаем цифру
			cmp al, 9d; если число больше 9 то это не число
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
			cmp ax, 10000d
				je next
			mul cx; увеличиваем множитель в 10 раз
			mov mult10, ax; кидаем обратно в переменную
			next:
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
			call writeEndline;
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
endm