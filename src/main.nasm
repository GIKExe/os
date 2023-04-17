%include "boot.nasm"
%include "pm.nasm"

lidt [IDTR]
hlt

%include "IDT.nasm"

int_EOI:
	push ax
	; Reset interrupt controllers
	mov al, 0x20
	out iSr_master, al
	out iSr_slave, al
	pop ax
	iretd

KEYBOARD_SPECIAL_KEY equ 0xE0
irq1_handler:
	pushf
	push ax
	push esi
	xor ax, ax
	xor esi, esi
	
.main:
	in al, 0x60
    cmp al, KEYBOARD_SPECIAL_KEY
    je .return
	; тут надо сохранять символ

.return:
	pop esi
	pop ax
	popf
	jmp int_EOI