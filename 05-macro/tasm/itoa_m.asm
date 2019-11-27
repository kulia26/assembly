itoa_m macro number
local make, start, print, print2, exit
local the_end, add_minus, zero, itoa_exit, set_not_print, null
		push cx
		push di
		xor cx, cx
		xor di, di
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
			inc di начало на первую цифру
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
			pop di
			pop cx
			jmp exit
		set_not_print:
			mov not_print, 1d;
			jmp start;
		null:
			mov ax, '0'
			mov [di], ax;
			inc di;
			dec cx;
			jmp itoa_exit
			jmp exit
		exit:
			exitm
endm