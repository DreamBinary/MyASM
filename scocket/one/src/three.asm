;**************************************                  *
;* coded by CXQ and ZHC
;**************************************

.model small       
.486 

ioport		equ 0210h
io8255a		equ ioport
io8255b     equ ioport+1h
io8255c		equ ioport+2h
io8255k		equ ioport+3h

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
	call init8255;设置A口、C上半口为方式0与输出、C下半口输入
again:	
	call wait4High;;等待PC0变成高电平,并在数码管上显示counter
	call countLight
	call wait4Low;;等待PC0变成低电平,并在数码管上显示counter
	jmp  again
  	hlt

init8255 proc
	mov dx, io8255k
	mov al, 10010001B;
	out dx, al
	ret
init8255 endp

wait4High proc	
nextL: 
	call dispNumber
	mov  dx,io8255c              
	in   al ,dx
	test al,01h;;;PC0等于0吗？
	jz   nextL
	ret 
wait4High endp

wait4Low proc
nextH: 
	call dispNumber
	mov   dx,io8255c             
	in    al ,dx
	test  al,01h;;;PC0等于0吗？
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
	mov dx, io8255a
	in al, dx
	mov kstate, al
	ret
readPA endp


dispNumber proc
    xor ax,ax	
	mov al,counter
	mov bx,offset leds
	xlat
	mov dx,io8255b
	out dx,al
	mov al,01000000B;对应PC6
	mov dx,io8255c
	out dx,al;;通过C口将PC6设置为1,点亮右边数码管，显示个位数。
	mov al,0
	out dx,al;;通过C口将PC6设置为0,熄灭右边数码管，不显示个位数。
	ret 
dispNumber endp 
    
code ends
end start
