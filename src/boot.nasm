[BITS 16]

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

; %macro wIDT 2
; 	dw (%2 - $$) & 0xFFFF
; 	dw %1
; 	db 0, 10001110b
; 	dw (%2 - $$) >> 16
; %endmacro

%macro wIDT 2
	dw (%2 - $$ + 0x7C00) & 0xFFFF
	dw %1
	db 0, 10001110b
	dw (%2 - $$ + 0x7C00) >> 16
%endmacro

; ==================================== BIOS ====================================
; установка видеорежима 3 = 80х25 символов
mov ah, 0x00
mov al, 3
int 0x10

; чтение секторов с диска A
mov ah, 0x02
mov al, 64     ; количество секторов для чтения
mov cx, 2      ; сектор старта чтения (начиная от 1, не 0)
mov dx, 0
xor bx, bx
mov es, bx
mov bx, 0x7E00 ; адрес на который будут записаны данные
int 0x13

jmp 0x8000

times 510 + $$ - $ db 0
dw 0xAA55

; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 0x7E00 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dw 0, 0
dw 0, 0 ; Esc
dw 0, "1!"
dw 0, "2@"
dw 0, "3#"
dw 0, "4$"
dw 0, "5%"
dw 0, "6^"
dw 0, "7&"
dw 0, "8*"
dw 0, "9("
dw 0, "0)"
dw 0, "-_"
dw 0, "=+"
dw 0, 0x0808 ; BackSpace
dw 0, 0      ; Tab ↹
dw 0, "qQ"
dw 0, "wW"
dw 0, "eE"
dw 0, "rR"
dw 0, "tT"
dw 0, "yY"
dw 0, "uU"
dw 0, "iI"
dw 0, "oO"
dw 0, "pP"
dw 0, "[{"
dw 0, "]}"
dw 0, 0x0A0A ; ↵ Enter
dw 0, 0      ; Левый Ctrl
dw 0, "aA"
dw 0, "sS"
dw 0, "dD"
dw 0, "fF"
dw 0, "gG"
dw 0, "hH"
dw 0, "jJ"
dw 0, "kK"
dw 0, "lL"
dw 0, ";:"
dw 0, 0x2227 ; " и '
dw 0, "`~"
dw 0, 0x0E0E ; Левый ⇧ Shift
dw 0, "\|"
dw 0, "zZ"
dw 0, "xX"
dw 0, "cC"
dw 0, "vV"
dw 0, "bB"
dw 0, "nN"
dw 0, "mM"
dw 0, ",<"
dw 0, ".>"
dw 0, "/?"
dw 0, 0x0F0F ; Правый ⇧ Shift
dw 0, 0
dw 0, 0      ; Левый Alt
dw 0, "  "   ; Space
dw 0, 0      ; ⇪ Caps Lock
dw 0, 0      ; F1
dw 0, 0      ; F2
dw 0, 0      ; F3
dw 0, 0      ; F4
dw 0, 0      ; F5
dw 0, 0      ; F6
dw 0, 0      ; F7
dw 0, 0      ; F8
dw 0, 0      ; F9
dw 0, 0      ; F10
dw 0, 0
dw 0, 0
dw 0, 0      ; Home
dw 0, 0x1818 ; up
dw 0, 0      ; Page Up
dw 0, 0
dw 0, 0x1B1B ; left
dw 0, 0
dw 0, 0x1A1A ; right
dw 0, 0
dw 0, 0      ; End
dw 0, 0x1919 ; down
dw 0, 0      ; Page Down
dw 0, 0      ; Insert
dw 0, 0      ; Delete
dw 0, 0
dw 0, 0
dw 0, 0
dw 0, 0      ; F11
dw 0, 0      ; F12
dw 0, 0
dw 0, 0
dw 0, 0      ; Левый ⊞ Win
dw 0, 0      ; Правый ⊞ Win
dw 0, 0      ; ≣ Menu
dw 0, 0      ; Power
dw 0, 0      ; Sleep
dw 0, 0
dw 0, 0
dw 0, 0
dw 0, 0      ; Wake
dw 0, 0
dw 0, 0
dw 0, 0
dw 0, 0
dw 0, 0
dw 0, 0
dw 0, 0
dw 0, 0
dw 0, 0
dw 0, 0
dw 0, 0
dw 0, 0
dw 0, 0
dw 0, 0
dw 0, 0
dw 0, 0
dw 0, 0
dw 0, 0
dw 0, 0
dw 0, 0
dw 0, 0
dw 0, 0
dw 0, 0
dw 0, 0
dw 0, 0
dw 0, 0
dw 0, 0
dw 0, 0

; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 0x8000 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
; ===================================== PM =====================================
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
	mov bl, 4
	mul bl
	mov bx, ax

	cmp bx, 512
	jb .on
	sub bx, 512
.off:
	and byte [bx+0x7E00], 00000010b
	jmp .return
.on:
	or byte [bx+0x7E00], 00000001b
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


section .text

global start
extern kmain   ;kmain определена в C-файле

start:
	call kmain
	; hlt        ;остановка процессора
	jmp $