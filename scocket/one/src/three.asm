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
	call init8255;����A�ڡ�C�ϰ��Ϊ��ʽ0�������C�°������
again:	
	call wait4High;;�ȴ�PC0��ɸߵ�ƽ,�������������ʾcounter
	call countLight
	call wait4Low;;�ȴ�PC0��ɵ͵�ƽ,�������������ʾcounter
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
	test al,01h;;;PC0����0��
	jz   nextL
	ret 
wait4High endp

wait4Low proc
nextH: 
	call dispNumber
	mov   dx,io8255c             
	in    al ,dx
	test  al,01h;;;PC0����0��
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
	mov al,01000000B;��ӦPC6
	mov dx,io8255c
	out dx,al;;ͨ��C�ڽ�PC6����Ϊ1,�����ұ�����ܣ���ʾ��λ����
	mov al,0
	out dx,al;;ͨ��C�ڽ�PC6����Ϊ0,Ϩ���ұ�����ܣ�����ʾ��λ����
	ret 
dispNumber endp 
    
code ends
end start
