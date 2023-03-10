
%macro print 1+
%endmacro

%macro integer 1
	db 'i'
	dw %%data.end - %%data
	%%data:
		%if %1 < 256
			db %1
		%elif %1 < 65536
			dw %1
		%endif
	%%data.end:
%endmacro

%macro string 1+
	db 's'
	dw %%data.end - %%data
	%%data:
		db %1
	%%data.end:
%endmacro

; dw 0x5511 запишется как 11 55
jmp $

; пример 1: деление меньшего на большее

dw 9262, 0, 38760

; 2E24 / 6897

function_div:
	pop si
	pop bx

	pushf
	mov ch, byte [si]
	mov cl, byte [bx]
	cmp cx, 0x6969 ; ii
	jne .end

	mov ch, byte [si+1]
	mov cl, byte [bx+1]
	cmp ch, cl
	jne .end


	mov cx, byte [si+1]
.lloop:
	dec cx
	; 
	mov ch, byte [di+si]
	mov cl, byte [bx+si]
	; 
	cmp cx, 0
	jne .lloop
.end:
	popf
	ret