use16
org 0x7C00

%define bool 1
%define string 2

%define u1 3
%define u2 4
%define u3 5
%define u4 6

%define i1 7
%define i2 8
%define i4 9
%define i8 10

%define unsigned_integer 12
%define integer 11

%macro del 1
	xor %1, %1
%endmacro

%macro mpush 1-*
	%rep %0
		push %1
		%rotate 1
	%endrep
%endmacro

%macro mpop 1-*
	%rep %0
		%rotate -1
		pop %1
	%endrep
%endmacro

%macro fclear 0
	pushf
	mpush AX, SI, DI
	mov AX, 3
	int 0x10
	mpop AX, SI, DI
	popf
%endmacro

%macro fprint 4+
	pushf
	mpush AX, BX, CX, DX, ES, BP, SI, DI
	del AX
	mov ES, AX

	%ifid %4
		mov BP, %4 + 5
		mov CX, word [%4 + 3]
	%else
		jmp %%data.end
		%%data:
			db %4
		%%data.end:
		mov BP, %%data
		mov CX, %%data.end - %%data
	%endif

	mov AX, 0x1301
	mov DL, %1 ; X
	mov DH, %2 ; Y
	mov BX, %3
	int 0x10
	mpop AX, BX, CX, DX, ES, BP, SI, DI
	popf
%endmacro

%macro fString 1-*
	jmp %%data.end
	db string
	%%size:
		dw 0
	%%data:
		%rep %0 
			db %1
			%rotate 1 
		%endrep
	%%data.end:
	mov word [%%size], %%data.end - %%data
%endmacro

%define clear() fclear
%define print(d+) fprint d
%define String(d+) fString d

main:
	msg: String("what? Test 002")
	clear()
	print(0, 0, 2, msg)

end:
	jmp end

status: db none

times 510 - ($-$$) db 0
dw 0x55AA