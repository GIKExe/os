[BITS 16]
; [ORG 0x7C00]

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

jmp key.end

times 510 + $$ - $ db 0
dw 0xAA55

key:
	dw 0
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
	dw 0x8 ; BS
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
	dw 0 ; ↵ Enter
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
.end: