;**************************************                  *
;* coded by CXQ and ZHC
;**************************************

.model small       
.486 

t0 equ 200h
t1 equ 201h
t2 equ 202h
tkz equ 203h

code  segment
assume cs: code
start:
	; init
	mov dx, tkz
	mov al, 00110110b
	out dx, al
	mov dx, t0
	mov ax, 1000
	out dx, al
	mov al, ah
	out dx, al
	
	mov dx, tkz
	mov al, 01110110b
	out dx, al
	mov dx, t1
	mov ax, 1000
	out dx, al
	mov al, ah
	out dx, al
	
	mov dx, tkz
	mov al, 10110100b  ; method 2
	out dx, al
	mov dx, t2
	mov ax, 2
	out dx, al
	mov al, ah
	out dx, al
	
	hlt
code ends
end start