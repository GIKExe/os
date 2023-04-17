
%macro wIDT 2
	dw (%2 - $$) & 0xFFFF
	dw %1
	db 0, 10001110b
	dw (%2 - $$) >> 16
%endmacro

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
	wIDT CODE_SELECTOR, int_EOI      ; 32    IRQ 0    System timer
	wIDT CODE_SELECTOR, irq1_handler ; 33    IRQ 1    Keyboard controller
	wIDT CODE_SELECTOR, int_EOI      ; 34    IRQ 2    Cascaded signals from IRQs 8–15 (from slave PIC)
	wIDT CODE_SELECTOR, int_EOI      ; 35    IRQ 3    Serial port controller for serial port 2 (shared with serial port 4, if present)
	wIDT CODE_SELECTOR, int_EOI      ; 36    IRQ 4    Serial port controller for serial port 1 (shared with serial port 3, if present)
	wIDT CODE_SELECTOR, int_EOI      ; 37    IRQ 5    Parallel port 2 and 3  or  sound card
	wIDT CODE_SELECTOR, int_EOI      ; 38    IRQ 6    Floppy disk controller
	wIDT CODE_SELECTOR, int_EOI      ; 39    IRQ 7    Parallel port 1. It is used for printers or for any parallel port if a printer is not present.
	; --- Slave PIC ----
	wIDT CODE_SELECTOR, int_EOI      ; 40    IRQ 8    Real-time clock (RTC)
	wIDT CODE_SELECTOR, int_EOI      ; 41    IRQ 9    Advanced Configuration and Power Interface (ACPI) system control interrupt on Intel chipsets
	wIDT CODE_SELECTOR, int_EOI      ; 42    IRQ 10   The Interrupt is left open for the use of peripherals
	wIDT CODE_SELECTOR, int_EOI      ; 43    IRQ 11   The Interrupt is left open for the use of peripherals
	wIDT CODE_SELECTOR, int_EOI      ; 44    IRQ 12   Mouse on PS/2 connector
	wIDT CODE_SELECTOR, int_EOI      ; 45    IRQ 13   CPU co-processor  or  integrated floating point unit  or  inter-processor interrupt
	wIDT CODE_SELECTOR, int_EOI      ; 46    IRQ 14   Primary ATA channel (ATA interface usually serves hard disk drives and CD drives)
	wIDT CODE_SELECTOR, int_EOI      ; 47    IRQ 15   Secondary ATA channel
  
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
; P=1 (the segment is present in physical memory)
; D=1 (the size of gate is 32 bit)
; DPL=0 (descriptor privilege level = 0)

; macro wIDT _selector, _offset
; {
; 	dw _offset and 0xFFFF ; Offset[0:15]
; 	dw _selector          ; Selector
; 	db 0                  ; reserved
; 	db 10001110b          ; P DPL[0:1] 0 D 1 1 0
; 	dw _offset shr 16     ; Offset[16:31]
; }

IDTR:
	dw $ - IDT - 1 ; 16-bit limit of the interrupt descriptor table
	dd IDT         ; 32-bit base address of the interrupt descriptor table