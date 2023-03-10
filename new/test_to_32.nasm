[org 0x7C00]
use16

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

mov ah, 0x00
mov al, 3
int 0x10

mov ah, 0x02
mov al, 16 ; количество секторов для чтения
mov cx, 2 ; сектор старта чтения (начиная от 1, не 0)
mov dx, 0
del bx
mov es, bx
mov bx, start
int 0x13

jmp start

times 510 + $$ - $ db 0
dw 0xAA55

start:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	
	mov sp, start
	mov bp, sp
	
	; Включаем линию A20
	in al, 0x92
	or al, 2
	out 0x92, al
 
	; Выключаем ВСЕ прерывания
	cli
	in  al, 0x70
	or  al, 0x80
	out 0x70, al ; Disable non-maskable interrupts
	
	; Загружаем Глобальную Таблицу Дескрепторов
	lgdt [GDTR]
	; lidt [IDTR]

	mov eax, cr0
	or  al, 1
	mov cr0, eax
 
	jmp 0x8:protected_entry

;===============================================================================
use32
protected_entry:
	mov ax, 16
	mov ds, ax
	mov ss, ax
	
	mov ax, 24
	mov es, ax

	; Включить прерывание клавиатуры
	; in al, 0x21
	; and al, 11111101b
	; out 0x21, al
	
	; Включить ВСЕ прерывания
	; in  al, 0x70
	; and al, 0x7F
	; out 0x70, al
	; sti

	mov byte [es:0], '?'
	mov byte [es:1], 4

	mov byte [es:2], 'X'
	mov byte [es:3], 4

	jmp $

%macro wGDT 4 ; ограничение, база, доступ, флаги
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

; https://wiki.osdev.org/Global_Descriptor_Table
GDT:
	; пустой дескриптор
	dq 0

	; дескриптор кода (селектор = 0x8)
	wGDT 0xFFFFF, 0, 10011010b, 1100b

	; дескриптор данных (селектор = 0x10)
	wGDT 0xFFFFF, 0, 10010010b, 1100b

	; дескриптор видеобуфера (селектор = 0x18)
	wGDT 0xFFFF, 0xB8000, 10010010b, 0100b

GDTR:
	dw $ - GDT - 1
	dd GDT