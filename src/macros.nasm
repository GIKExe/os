; ; macro mpop [reg] { reverse pop reg }

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

%macro wGDT 4 ; limit, base, access, flags
	; 2 байта ограничение
	dw %1 & 0xFFFF

	; 3 байта база
	dw %2 & 0xFFFF
	db (%2 >> 16) & 0xFF

	; байт доступ
	db %3

	; 4 бита ограничение и 4 бита флаги
	db ((%4 & 0xF) << 4) + ((%1 >> 16) & 0xF)

	; байт база
	db (%2 >> 24)
%endmacro

; Interrupt gate descriptor format
; BITS  | SIZE | FIELD
; ------+------+------
; 0-15  |  16  | Offset[0:15]
; 16-31 |  16  | Selector[0:15]
; 32-39 |   8  | reserved
; 40-47 |   8  | P DPL[0:1] 0 D 1 1 0
; 48-63 |  16  | Offset[16:31]

; The following macro defines an interrupt gate descriptor.
; The following assumtions take place:
; P=1 (сегмент присутствует в физической памяти)
; D=1 (размер элемента управления составляет 32 бита)
; DPL=0 (descriptor privilege level = 0)

%macro wIDT 2
	dw (%2 - $$ + 0x7C00) & 0xFFFF
	dw %1
	db 0, 10001110b
	dw (%2 - $$ + 0x7C00) >> 16
%endmacro