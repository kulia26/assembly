include init.asm
include func.asm
include itoa_m.asm
include atoi_m.asm

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
	
	enter_x                db 'Enter x -32736..32767 (press enter to exit): ', '$'
	enter_y                db 'Enter y -32736..32767 (press enter to exit): ', '$'

	string 				   db 7 dup ('$')
	s_invalid              db 'error: not in -32736..32767 range$'
	s_invalid_z            db 'error: Z not in -32736..32767 range$'
	s_incorrect_err        db 'error: incorrect symbol$'
	s_overflow             db 'overflow: Z not in -32736..32767 range$'
	s_overflow1            db 'overflow: x*y not in -32736..32767 range$'
	s_result               db 'z = $'
	plus_s                 db ' + $'
	div_s                  db '/$'

	endline                db 13d,10d,'$'   ;"\cr"
	
dseg ends

cseg segment para public 'code'
	main proc far
		init cseg, dseg, stseg
		program_loop:
			loop_x:
			call writeEndline;
			lea dx, enter_x; ; write "Enter x"
			call write
			
			call read_x
			cmp buffer + 1, 0;
				je exit;
				
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
			cmp buffer + 1, 0;
				je exit;
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
			lea dx, s_result; ; write "Result"
			call write
			lea dx, string; ; write "Enter x"
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
				lea dx, plus_s; ; write "целое"
				call write
				lea dx, string; ; write "целое"
				call write
				lea dx, div_s; ; write "целое"
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
		atoi_m buffer
		ret
	atoi endp

	itoa proc near
		itoa_m number
		ret
	itoa endp


	function proc near
		func x, y
		ret
	function endp
	
	overflow proc near
		call writeEndline;
		lea dx, s_overflow
		mov ah, 9d
		int 21h
		add ax, 30000d;
		add ax, 30000d;
		ret
	overflow endp
	
	overflow1 proc near
		call writeEndline;
		lea dx, s_overflow1
		mov ah, 9d
		int 21h
		add ax, 30000d;
		add ax, 30000d;
		ret
	overflow1 endp
	
	read_x proc near
		lea dx, buffer
		mov ah, 10
		int 21h
		ret
	read_x endp
	
	read_y proc near
		lea dx, buffer
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
