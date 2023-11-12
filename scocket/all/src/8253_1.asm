;**************************************
;* coded by CXQ
; 用 8253 产生产生周期为 5 秒 ,负脉冲宽度为 1 秒的连续脉冲，并用该连续脉冲驱动一个 LED
;**************************************

.model small       
.486 

T0_8253 equ 210h
T1_8253 equ 211h
T2_8253 equ 212h
CTR_8253 equ 213h

code  segment
assume cs: code
start:
	; init
	mov dx, CTR_8253
	mov al, 00110110b
	out dx, al
	mov dx, T0_8253
	mov ax, 1000
	out dx, al
	mov al, ah
	out dx, al
	
	mov dx, CTR_8253
	mov al, 01110110b
	out dx, al
	mov dx, T1_8253
	mov ax, 1000
	out dx, al
	mov al, ah
	out dx, al
	
	mov dx, CTR_8253
	mov al, 10110100b  ; method 2
	out dx, al
	mov dx, T2_8253
	mov ax, 5
	out dx, al
	mov al, ah
	out dx, al
	
	hlt
code ends
end start