; {'iso': true}

use16
org 0x7C00

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

%macro f_clear 0
	pushf
	mpush AX, SI, DI
	mov AX, 3
	int 0x10
	mpop AX, SI, DI
	popf
%endmacro

%macro f_print 4+
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

%define clear() f_clear
%define print(d+) f_print d

pushf
mpush AX, BX, CX, DX, DS, ES

del AX          ; быстрое обнуление
mov ES, AX      ; очистка смещения
; mov DS, AX

; SECTOR
mov CL, 2       ; номер начального сектора (начиная от 1)
mov AL, 32      ; сколько секторов читать

; HDD
mov CH, 0       ; from cylinder number 0
mov DH, 0       ; head number 0

; FUNCTION
mov AH, 2       ; номер функции
mov BX, 0x7E00  ; 512 байтов от исходного адреса 0x7C00
int 0x13

mpop AX, BX, CX, DX, DS, ES
popf

jc error_1

cmp word [0x7E02], 1999
jne error_2

jmp 0x7E00

error_1:
	clear()
	print(0, 0, 4, "[1] ERROR: failed to read disk")
	jmp end

error_2:
	clear()
	print(0, 0, 4, "[2] ERROR: data is corrupted")
	jmp end

end:
	jmp end

times 510-($-$$) db 0 
dw 0xAA55