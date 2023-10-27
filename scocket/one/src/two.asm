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
	kstate db ?
	lighter db ?
data ends

code  segment
assume cs:code,ds:data
start:	
    mov  ax,data
	mov  ds,ax
	call init8255;设置A口、C上半口为方式0与输出、C下半口输入
again:	
	call delayAll
	call countLight
	jmp  again
  	hlt

init8255 proc
	mov dx, io8255k
	mov al, 10010001B;
	out dx, al
	ret
init8255 endp

delayAll proc
	mov cx, 1000
ag:
	call delay
	loop ag
delayAll endp

delay proc
	call wait4High
	call wait4Low
delay endp

wait4High proc	
nextL: 
	mov  dx,io8255c              
	in   al ,dx
	test al,01h;;;PC0等于0吗？
	jz   nextL
	ret 
wait4High endp

wait4Low proc
nextH: 
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
	
	cmp bl, 3
	jna green
	cmp bl, 6
	jna yellow
	jmp red
	
green:
	mov lighter, 00000100B;
	jmp final
yellow:
	mov lighter, 00000010B;
	jmp final
red:
	mov lighter, 00000001B;
final:
	call writePB
	ret 
countLight endp

readPA proc
	mov dx, io8255a
	in al, dx
	mov kstate, al
	ret
readPA endp


writePB proc
	mov al, lighter
	mov dx, io8255b
	out dx, al
	ret
writePB endp
    
code ends
end start
