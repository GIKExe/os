%include "boot.asm"
%include "pm.asm"

section .text

global start
extern kmain   ;kmain определена в C-файле

start:
	call kmain
	; hlt        ;остановка процессора
	jmp $