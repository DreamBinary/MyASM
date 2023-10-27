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
	d0    db   0 ;;;���counter��λ��
	d1    db   0;;;���counterʮλ��
data ends

code  segment
assume cs:code,ds:data
start:	
    mov  ax,data
	mov  ds,ax
	call init8255;����A�ڡ�C�ϰ��Ϊ��ʽ0�������C�°������
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
	test al,01h;;;PC0����0��
	jz   nextL
	ret 
wait4High endp

waitLow proc
nextH2: 
	call dispNumber
	mov   dx,io8255c             
	in    al ,dx
	test  al,02h;;;PC0����0��
	jnz  nextH2
	ret 
waitLow endp

wait4Low proc
nextH: 
	call dispNumber
	mov   dx,io8255c             
	in    al ,dx
	test  al,01h;;;PC0����0��
	jnz  nextH
	ret 
wait4Low endp

dispNumber proc
    xor ax,ax	
	mov al,counter
	mov bl,10
	div bl ;;counter����10
	mov d1,al;;al�����̣���dlΪcounter��ʮλ�ϵ�����
	mov d0,ah;;ah������������d0Ϊcounter�ĸ�λ�ϵ�����
	
	mov al,d0
	mov bx,offset leds
	xlat  ;;ִ�����ָ�al=d0�Ķ���
	mov dx,io8255b
	out dx,al;;��d0�Ķ������A��
	mov al,01000000B;��ӦPC6
	mov dx,io8255c
	out dx,al;;ͨ��C�ڽ�PC6����Ϊ1,�����ұ�����ܣ���ʾ��λ����
	mov al,0
	out dx,al;;ͨ��C�ڽ�PC6����Ϊ0,Ϩ���ұ�����ܣ�����ʾ��λ����
	mov al,d1
	mov bx,offset leds
	xlat 
	mov dx,io8255b
	out dx,al;;��d1�Ķ������A��
	mov al,10000000B;;;��ӦPC7
	mov dx,io8255c
	out dx,al;;ͨ��C�ڽ�PC7����Ϊ1,�����Ҷ�����ܣ���ʾʮλ����
	mov al,0
	out dx,al;;ͨ��C�ڽ�PC7����Ϊ0,Ϩ�����Ҷ�����ܣ�����ʾʮλ����
	ret 
dispNumber endp 
    
code ends
end start
