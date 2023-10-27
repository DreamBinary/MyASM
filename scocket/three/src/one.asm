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
	mov al, 00110000b
	out dx, al
	
	mov dx, t0
	mov ax, 9  ; first high level -->> write 9 from init register to sub one register
	out dx, al
	mov al, ah
	out dx, al
	; high -->> light led
	hlt
code ends
end start