;**************************************
;* coded by fiv
; 试在实验箱上设计一个系统，该系统每收到一个正脉冲，就读取一次实验箱上
; 八个开关 Ki 的电平，并统计其高电平开关的数量 H，然后将 H 显示在实验箱的
; 一个七段数码管上。
;**************************************

.model small
.486
PA_8255   equ  200h
PB_8255   equ  201h
PC_8255   equ  202h
CTR_8255  equ  203h

data  segment
	leds   db   3fh,06h,5bh,4fh,66h
	       db   6dh,7dh,07h,7fh,6fh
	kstate db ?
	counter db ?
data ends

code  segment
assume cs:code,ds:data
start:
    mov  ax,data
	mov  ds,ax
	call init8255
again:
	call wait4High
	call countLight
	call wait4Low
	jmp  again
  	hlt

init8255 proc
	mov dx, CTR_8255
	mov al, 10010001B;
	out dx, al
	ret
init8255 endp

wait4High proc
nextL:
	call dispNumber
	mov  dx,PC_8255
	in   al ,dx
	test al,01h
	jz   nextL
	ret
wait4High endp

wait4Low proc
nextH:
	call dispNumber
	mov   dx,PC_8255
	in    al ,dx
	test  al,01h
	jnz  nextH
	ret
wait4Low endp

countLight proc
	call readPA
	mov al, kstate
	mov bl, 0
	mov cx, 8
lp:
	shl al, 1
	jnc next
	inc bl
next:
	loop lp

	mov counter, bl
	ret
countLight endp

readPA proc
	mov dx, PA_8255
	in al, dx
	mov kstate, al
	ret
readPA endp


dispNumber proc
    xor ax,ax
	mov al,counter
	mov bx,offset leds
	xlat
	mov dx,PB_8255
	out dx,al
	mov al,01000000B
	mov dx,PC_8255
	out dx,al
	mov al,0
	out dx,al
	ret
dispNumber endp

code ends
end start
