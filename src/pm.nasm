dw 0             ; 0x7E00
dw 0 ; Esc
dw "1"
dw "2"
dw "3"
dw "4"
dw "5"
dw "6"
dw "7"
dw "8"
dw "9"
dw "0"
dw "-"
dw "="
dw 0x08 ; BackSpace
dw 0 ; Tab ↹
dw "q"
dw "w"
dw "e"
dw "r"
dw "t"
dw "y"
dw "u"
dw "i"
dw "o"
dw "p"
dw "["
dw "]"
dw 0x0A ; ↵ Enter
dw 0 ; Левый Ctrl
dw "a"
dw "s"
dw "d"
dw "f"
dw "g"
dw "h"
dw "j"
dw "k"
dw "l"
dw ";"
dw 0 ; " и '
dw "`"
dw 0 ; Левый ⇧ Shift
dw "\"
dw "z"
dw "x"
dw "c"
dw "v"
dw "b"
dw "n"
dw "m"
dw ","
dw "."
dw "/"
dw 0 ; Правый ⇧ Shift
dw 0
dw 0 ; Левый Alt
dw 0 ; Space
dw 0 ; ⇪ Caps Lock
dw 0 ; F1
dw 0 ; F2
dw 0 ; F3
dw 0 ; F4
dw 0 ; F5
dw 0 ; F6
dw 0 ; F7
dw 0 ; F8
dw 0 ; F9
dw 0 ; F10
dw 0
dw 0
dw 0 ; Home
dw 0x18 ; up
dw 0 ; Page Up
dw 0
dw 0x1B ; left
dw 0
dw 0x1A ; right
dw 0
dw 0 ; End
dw 0x19 ; down
dw 0 ; Page Down
dw 0 ; Insert
dw 0 ; Delete
dw 0
dw 0
dw 0
dw 0 ; F11
dw 0 ; F12
dw 0
dw 0
dw 0 ; Левый ⊞ Win
dw 0 ; Правый ⊞ Win
dw 0 ; ≣ Menu
dw 0 ; Power
dw 0 ; Sleep
dw 0
dw 0
dw 0
dw 0 ; Wake
dw 0
dw 0
dw 0
dw 0
dw 0
dw 0
dw 0
dw 0
dw 0
dw 0
dw 0
dw 0
dw 0
dw 0
dw 0
dw 0
dw 0
dw 0
dw 0
dw 0
dw 0
dw 0
dw 0
dw 0
dw 0
dw 0
dw 0
dw 0

; 0x7F00
%include "macros.nasm"

; переход в защищённый режим (32 бита)
mov ax, cs
mov ds, ax
mov es, ax
mov ss, ax

; mov sp, protected_entry ; вершина стека
mov sp, 0x7C00 ; вершина стека
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

	; код (селектор = 0x08)
	wGDT 0xFFFFF, 0, 10011010b, 1100b

	; данные (селектор = 0x10)
	wGDT 0xFFFFF, 0, 10010010b, 1100b

	; видеобуфер (селектор = 0x18)
	wGDT 0xFFFF, 0xB8000, 10010010b, 0100b

GDTR:
	dw $ - GDT - 1
	dd GDT


CODE_SELECTOR equ 0x8
IDT:
	dq 0 ; 0    #DE   Fault        Error code No     Divide Error
	dq 0 ; 1    #DB   Fault/Trap   Error code No     Debug Exception (For Intel use only)
	dq 0 ; 2     -    Interrupt    Error code No     Nonmaskable external interrupt
	dq 0 ; 3    #BP   Trap         Error code No     Breakpoint
	dq 0 ; 4    #OF   Trap         Error code No     Overflow
	dq 0 ; 5    #BR   Fault        Error code No     BOUND Range Exceeded
	dq 0 ; 6    #UD   Fault        Error code No     Invalid Opcode (Undefined Opcode)
	dq 0 ; 7    #NM   Fault        Error code No     Device Not Available (No Math Coprocessor)
	dq 0 ; 8    #DF   Abort        Error code Zero   Double Fault
	dq 0 ; 9          Fault        Error code Yes    Coprocessor Segment Overrun (reserved)
	dq 0 ; 10   #TS   Fault        Error code Yes    Invalid TSS
	dq 0 ; 11   #NP   Fault        Error code Yes    Segment Not Present
	dq 0 ; 12   #SS   Fault        Error code Yes    Stack-Segment Fault
	dq 0 ; 13   #GP   Fault        Error code Yes    General Protection
	dq 0 ; 14   #PF   Fault        Error code Yes    Page Fault  
	dq 0 ; 15    -                 Error code No     Intel reserved. Do not use.
	dq 0 ; 16  
	dq 0 ; 17   #MF   Fault        Error code No     x87 FPU Floating-Point Error (Math Fault)
	dq 0 ; 18   #MC   Abort        Error code No     Machine Check
	dq 0 ; 19   #XM   Fault        Error code No     SIMD Floating-Point Exception
	dq 0 ; 20   #VE   Fault        Error code No     Virtualization Exception
	dq 0 ; 21    -                                   Intel reserved. Do not use.
	dq 0 ; 22    -                                   Intel reserved. Do not use.
	dq 0 ; 23    -                                   Intel reserved. Do not use.
	dq 0 ; 24    -                                   Intel reserved. Do not use.
	dq 0 ; 25    -                                   Intel reserved. Do not use.
	dq 0 ; 26    -                                   Intel reserved. Do not use.
	dq 0 ; 27    -                                   Intel reserved. Do not use.
	dq 0 ; 28    -                                   Intel reserved. Do not use.
	dq 0 ; 29    -                                   Intel reserved. Do not use.
	dq 0 ; 30    -                                   Intel reserved. Do not use.
	dq 0 ; 31    -                                   Intel reserved. Do not use.
	; --- Master PIC ---
	wIDT CODE_SELECTOR, ric      ; 32    IRQ 0    System timer
	wIDT CODE_SELECTOR, irq1_handler ; 33    IRQ 1    Keyboard controller
	wIDT CODE_SELECTOR, ric      ; 34    IRQ 2    Cascaded signals from IRQs 8–15 (from slave PIC)
	wIDT CODE_SELECTOR, ric      ; 35    IRQ 3    Serial port controller for serial port 2 (shared with serial port 4, if present)
	wIDT CODE_SELECTOR, ric      ; 36    IRQ 4    Serial port controller for serial port 1 (shared with serial port 3, if present)
	wIDT CODE_SELECTOR, ric      ; 37    IRQ 5    Parallel port 2 and 3  or  sound card
	wIDT CODE_SELECTOR, ric      ; 38    IRQ 6    Floppy disk controller
	wIDT CODE_SELECTOR, ric      ; 39    IRQ 7    Parallel port 1. It is used for printers or for any parallel port if a printer is not present.
	; --- Slave PIC ----
	wIDT CODE_SELECTOR, ric      ; 40    IRQ 8    Real-time clock (RTC)
	wIDT CODE_SELECTOR, ric      ; 41    IRQ 9    Advanced Configuration and Power Interface (ACPI) system control interrupt on Intel chipsets
	wIDT CODE_SELECTOR, ric      ; 42    IRQ 10   The Interrupt is left open for the use of peripherals
	wIDT CODE_SELECTOR, ric      ; 43    IRQ 11   The Interrupt is left open for the use of peripherals
	wIDT CODE_SELECTOR, ric      ; 44    IRQ 12   Mouse on PS/2 connector
	wIDT CODE_SELECTOR, ric      ; 45    IRQ 13   CPU co-processor  or  integrated floating point unit  or  inter-processor interrupt
	wIDT CODE_SELECTOR, ric      ; 46    IRQ 14   Primary ATA channel (ATA interface usually serves hard disk drives and CD drives)
	wIDT CODE_SELECTOR, ric      ; 47    IRQ 15   Secondary ATA channel

IDTR:
	dw $ - IDT - 1 ; 16-bit limit of the interrupt descriptor table
	dd IDT         ; 32-bit base address of the interrupt descriptor table


[BITS 32]
master_command equ 0x20
master_data    equ 0x21

slave_command  equ 0xA0
slave_data     equ 0xA1

ric: ; Reset interrupt controllers
	push ax
	mov al, 0x20
	out master_command, al
	out slave_command, al
	pop ax
	iretd


KEYBOARD_SPECIAL_KEY equ 0xE0
irq1_handler:
	pushf
	push ax
	push bx
	xor ax, ax
.main:
	in al, 0x60
	cmp al, 0x80
	jb .next
	sub al, 0x80
.next:
	mov bl, 2
	mul bl
	mov bx, ax
	xor byte [bx+0x7E01], 1
.return:
	pop bx
	pop ax
	popf
	jmp ric


protected_entry:
	mov ax, 16
	mov ds, ax
	mov ss, ax

	mov ax, 24
	mov es, ax

	lidt [IDTR]

	; Initialize Programmable Interrupt Controller (PIC)
	; -------- master i8259A PIC initialization --------
	mov al, 00010001b
	out master_command, al
	   
	; Define interrupt vector for the 0th line of PIC
	mov al, 0x20 ; (interrupt vector No 32)
	out master_data, al
	   
	; Bit mask defines the line of master i8259A to which slave i8259A is connected
	mov al, 00000100b ; (line No 2)
	out master_data, al
	   
	mov al, 00000001b
	out master_data, al
	   
	; -------- slave i8259A PIC initialization ---------
	mov al, 00010001b
	out slave_command, al
	   
	; Define interrupt vector for the 0th line of PIC
	mov al, 0x28 ; (interrupt vector No 40)
	out slave_data, al
	   
	; Defines the line number through which slave i8259A is connected to master i8259A
	mov al, 00000010b ; (line No 2)
	out slave_data, al
	   
	mov al, 00000001b
	out slave_data, al

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