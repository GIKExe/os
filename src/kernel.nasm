[BITS 16]
[ORG 0x0000] 

mov ah, 0x00
mov al, 0x03
int 0x10

mov ah, 0x09
mov al, 's'
mov bh, 0x00
mov bl, 0x05
mov cx, 0x01
int 0x10

jmp $

; bootloader_start:
; 	mov ah, 00h
; 	mov al, 03h
; 	int 10h

; 	mov ah, 01h
; 	mov cx, 2607h
; 	int 10h

; 	mov ah, 09h
; 	mov bh, 00h
; 	mov bl, 02h
; 	mov cx, 01h
; 	mov si, msg

; .print:
; 	mov al, [si]
; 	cmp al, 00h
; 	je .end
; 	inc si
; 	int 10h
; 	call cursor
; 	jmp .print

; .end:
; 	jmp .end

; cursor:
; 	push ax
; 	push bx
; 	push cx
; 	push dx
; .get_pos:
; 	mov ah, 03h
; 	mov bh, 00h
; 	int 10h
; .c0:
; 	cmp dl, 79
; 	je .c1
; 	inc dl
; 	jmp .set_pos
; .c1:
; 	cmp dh, 24
; 	je .reset
; 	mov dl, 00h
; 	inc dh
; 	jmp .set_pos
; .reset:
; 	mov dx, 0000h
; .set_pos:
; 	mov ah, 02h
; 	int 10h
; .exit:
; 	pop dx
; 	pop cx
; 	pop bx
; 	pop ax
; 	ret

; msg db 'Hello World!', 0