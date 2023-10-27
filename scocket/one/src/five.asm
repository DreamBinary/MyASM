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
	counter db 60
	d0    db   0 ;;;存放counter个位数
	d1    db   0;;;存放counter十位数
data ends

code  segment
assume cs:code,ds:data
start:	
    mov  ax,data
	mov  ds,ax
	call init8255;设置A口、C上半口为方式0与输出、C下半口输入
s:
	mov counter, 60
	call waitLow;
again:	
	call delayOne;
	dec counter;
	cmp counter, 0
	jna s
	jmp  again
  	hlt

init8255 proc
	mov dx, io8255k
	mov al, 10010001B;
	out dx, al
	ret
init8255 endp

delayOne proc
	mov cx, 1000
ag:
	call delay
	loop ag
delayOne endp

delay proc
	call wait4High
	call wait4Low
delay endp

wait4High proc	
nextL: 
call dispNumber
	mov  dx,io8255c              
	in   al ,dx
	test al,01h;;;PC0等于0吗？
	jz   nextL
	ret 
wait4High endp

waitLow proc
nextH2: 
	call dispNumber
	mov   dx,io8255c             
	in    al ,dx
	test  al,02h;;;PC0等于0吗？
	jnz  nextH2
	ret 
waitLow endp

wait4Low proc
nextH: 
	call dispNumber
	mov   dx,io8255c             
	in    al ,dx
	test  al,01h;;;PC0等于0吗？
	jnz  nextH
	ret 
wait4Low endp

dispNumber proc
    xor ax,ax	
	mov al,counter
	mov bl,10
	div bl ;;counter除以10
	mov d1,al;;al等于商，故dl为counter的十位上的数；
	mov d0,ah;;ah等于余数，故d0为counter的个位上的数；
	
	mov al,d0
	mov bx,offset leds
	xlat  ;;执行完该指令，al=d0的段码
	mov dx,io8255b
	out dx,al;;将d0的段码输出A口
	mov al,01000000B;对应PC6
	mov dx,io8255c
	out dx,al;;通过C口将PC6设置为1,点亮右边数码管，显示个位数。
	mov al,0
	out dx,al;;通过C口将PC6设置为0,熄灭右边数码管，不显示个位数。
	mov al,d1
	mov bx,offset leds
	xlat 
	mov dx,io8255b
	out dx,al;;将d1的段码输出A口
	mov al,10000000B;;;对应PC7
	mov dx,io8255c
	out dx,al;;通过C口将PC7设置为1,点亮右二数码管，显示十位数。
	mov al,0
	out dx,al;;通过C口将PC7设置为0,熄灭右右二数码管，不显示十位数。
	ret 
dispNumber endp 
    
code ends
end start
