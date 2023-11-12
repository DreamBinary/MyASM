;**************************************
;* coded by CXQ
; 试用 0832 产生 1v, 2v, 3v, 4v, 4.5v 电压，每种电压输出持续 3 秒。
;**************************************

.model small       
.486  ;; 486 指令集

PA_8255   equ  200h
PB_8255   equ  201h
PC_8255   equ  202h
CTR_8255  equ  203h

T0_8253   equ  210h
T1_8253   equ  211h
T2_8253   equ  212h
CTR_8253  equ  213h

A0_M8259  equ  230h
A1_M8259  equ  231h
A0_S8259  equ  240h
A1_S8259  equ  241h

IN0_0809  equ  260h
ADDR_0832 equ  270h 


data  segment
	nv db 153, 179, 204, 230, 243  ; 1v, 2v, 3v, 4v, 4.5v
data ends

code  segment
assume cs:code, ds:data
start:	
	mov dx, CTR_8253
	mov al, 00110110b
	out dx, al
	mov dx, T0_8253
	mov ax, 100
	out dx, al
	mov al, ah
	out dx, al

    mov ax, data  ;; if use data
    mov ds, ax
kk:
    mov si, 0
again:
    cmp si, 5
    jge kk
    mov dx, ADDR_0832
    mov al, nv[si]
    out dx, al
  	call delay3s
  	inc si
  	jmp again
  	hlt
  	
delay3s proc
	mov bx, 300  ;
	call setTimer ;; mode = 0
again3s:
	mov dx, PC_8255
	in al, dx
	test al, 01h
	jz again3s
	ret
delay3s endp
  	
setTimer proc
	mov dx, CTR_8253
	mov al, 00110000b
	out dx, al
	mov ax, bx
	mov dx, T0_8253
	out dx, al
	mov al, ah
	out dx, al
	ret
setTimer endp
  	
code ends
end start
; v = n * 5 / 128 - 5
; n = (v + 5) * 128 / 5
