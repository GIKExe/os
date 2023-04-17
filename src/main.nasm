%include "boot.nasm"
%include "pm.nasm"

section .text

global start
extern kmain   ;kmain определена в C-файле

start:
	call kmain
	hlt        ;остановка процессора