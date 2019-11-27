include init.asm
include itoa_m.asm
include atoi_m.asm

stseg segment para stack 'stack'
	db 64 dup ('stack')
stseg ends	

dseg segment para public 'data' 
	number                 dw 0h
	s_enter_num            db 'Enter number -32736..32767 (press enter to exit): ', '$'
	task                   db '  -32 =$'		
	string 				   db 7 dup (' '), '$'
	s_invalid              db 'error: number not in -32736..32767 range$'
	s_incorrect_err        db 'error: incorrect symbol$'

	endline                db 13d,10d,'$'   ;"\cr"
	buffer                 db 7, 'N', 7 dup('$'), '$'; buffer '6??????'+endline
	
	not_print              dw 1
	mult10                 dw 1d
	div10                  dw 10000d
dseg ends

cseg segment para public 'code'
	main proc far
		init cseg, dseg, stseg
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
			call itoa
			lea dx, task;
			call write
			call writeEndline
			lea dx, string;
			call write
			jmp program_loop
			exit:
				ret
	main endp
	
	atoi proc near
		atoi_m buffer
		ret
	atoi endp

	itoa proc near
		itoa_m number
		ret
	itoa endp
	
	writeEndline proc
		lea dx, endline
		mov ah, 9
		int 21h
		ret
	writeEndline endp
	
	write proc
		mov ah, 9
		int 21h
		ret
	write endp
	
	read proc
		lea dx, buffer
		mov ah, 10
		int 21h
		ret
	read endp
	
cseg ends
end main
