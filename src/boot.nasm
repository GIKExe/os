[BITS 16]

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

jmp 0x7F00

times 510 + $$ - $ db 0
dw 0xAA55