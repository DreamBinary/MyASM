;**************************************                  *
;* coded by CXQ
; 用 8253 接收正脉冲，接收十个正脉冲时，点亮 1 个红色 LED 灯。
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
	mov dx, CTR_8253
	mov al, 00110000b
	out dx, al
	
	mov dx, T0_8253
	mov ax, 9  ; first high level -->> write 9 from init register to sub one register
	out dx, al
	mov al, ah
	out dx, al
	; high -->> light led
	hlt
code ends
end start