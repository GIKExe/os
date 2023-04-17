
; переход в защищённый режим (32 бита)
mov ax, cs
mov ds, ax
mov es, ax
mov ss, ax

mov sp, protected_entry ; вершина стека
mov bp, sp
	
; Включаем линию A20
in al, 0x92
or al, 2
out 0x92, al

; Выключаем ВСЕ прерывания
cli
in al, 0x70
or al, 0x80
out 0x70, al ; Disable non-maskable interrupts
	
; Загружаем Таблицы Дескрепторов
lgdt [GDTR]

mov eax, cr0
or  al, 1
mov cr0, eax
 
jmp 0x8:protected_entry

; https://wiki.osdev.org/Global_Descriptor_Table
GDT:
	; пустой
	dq 0

	; ; код (селектор = 0x08)
	; wGDT 0xFFFFF, 0, 10011010b, 1100b
	dw 0xFFFF, 0
	db 0, 10011010b, 11001111b, 0

	; ; данные (селектор = 0x10)
	; wGDT 0xFFFFF, 0, 10010010b, 1100b
	dw 0xFFFF, 0
	db 0, 10010010b, 11001111b, 0

	; ; видеобуфер (селектор = 0x18)
	; wGDT 0xFFFF, 0xB8000, 10010010b, 0100b
	dw 0xFFFF, 0x8000
	db 0xB, 10010010b, 01000000b, 0

GDTR:
	dw $ - GDT - 1
	dd GDT



[BITS 32]
protected_entry:
	mov ax, 16
	mov ds, ax
	mov ss, ax

	mov ax, 24
	mov es, ax

	; Initialize Programmable Interrupt Controller (PIC)
	iSr_master equ 0x20
	iMr_master equ 0x21
	   
	iSr_slave equ 0xA0    
	iMr_slave equ 0xA1

	; -------- master i8259A PIC initialization --------
	mov al, 00010001b
	out iSr_master, al
	   
	; Define interrupt vector for the 0th line of PIC
	mov al, 0x20 ; (interrupt vector No 32)
	out iMr_master, al
	   
	; Bit mask defines the line of master i8259A to which slave i8259A is connected
	mov al, 00000100b ; (line No 2)
	out iMr_master, al
	   
	mov al, 00000001b
	out iMr_master, al
	   
	; -------- slave i8259A PIC initialization ---------
	mov al, 00010001b
	out iSr_slave, al
	   
	; Define interrupt vector for the 0th line of PIC
	mov al, 0x28 ; (interrupt vector No 40)
	out iMr_slave, al
	   
	; Defines the line number through which slave i8259A is connected to master i8259A
	mov al, 00000010b ; (line No 2)
	out iMr_slave, al
	   
	mov al, 00000001b
	out iMr_slave, al

	; Включить прерывание клавиатуры
	in al, 0x21
	and al, 11111101b
	out 0x21, al

	; Включить немаскируемые прерывания
	in  al, 0x70
	and al, 0x7F
	out 0x70, al

	; Включить маскируемые прерывания
	sti