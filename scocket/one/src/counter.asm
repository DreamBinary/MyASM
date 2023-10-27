;**************************************
;*           ѭ������100              *
;* ��Ʒ���2�Ĵ��룬�÷�������ʵ����  *
;* ��ʵ��                             *
;* coded by NYT   2023.9.20
;**************************************

.model small       
.486 

ioport		equ 0210h
io8255a		equ ioport
io8255c		equ ioport+2h
io8255k		equ ioport+3h

data  segment
	leds   db   3fh,06h,5bh,4fh,66h
	       db   6dh,7dh,07h,7fh,6fh
	counter db   ?  
	d0    db   0 ;;;���counter��λ��
	d1    db   0;;;���counterʮλ��
data ends

code  segment
assume cs:code,ds:data
start:	
        mov  ax,data
	mov  ds,ax
	mov  counter,0
	call init8255;����A�ڡ�C�ϰ��Ϊ��ʽ0�������C�°������
again:	call wait4High;;�ȴ�PC0��ɸߵ�ƽ,�������������ʾcounter
	call wait4Low;;�ȴ�PC0��ɵ͵�ƽ,�������������ʾcounter
	call addCounter;;counter����1��������99��counter���ó�0
	jmp  again
  	hlt

init8255 proc
	mov dx,io8255k    ;��8255��ΪA��C�Ͽ�����¿�����
	mov al,10000001b;
	out dx,al
	ret 
init8255 endp

wait4High proc	
nextL:  call dispNumber;;;;�����������ʾcounter
	mov  dx,io8255c              
	in   al ,dx
	test al,01h;;;PC0����0��
	jz   nextL
	ret 
wait4High endp

wait4Low proc
nextH:  call  dispNumber;;;;�����������ʾcounter
	mov   dx,io8255c             
	in    al ,dx
	test  al,01h;;;PC0����0��
	jnz  nextH
	ret 
wait4Low endp

addCounter proc
	inc counter ;;counter ����1
	xor ax,ax
	mov al,counter
	mov bl,100
	div bl ;;counter����100
	mov counter,ah;;;ah��������
	ret 
addCounter endp

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
	mov dx,io8255a
	out dx,al;;��d0�Ķ������A��
	mov al,01000000B;��ӦPC6
	mov dx,io8255c
	out dx,al;;ͨ��C�ڽ�PC6����Ϊ1,�����ұ�����ܣ���ʾ��λ����
	mov al,0
	out dx,al;;ͨ��C�ڽ�PC6����Ϊ0,Ϩ���ұ�����ܣ�����ʾ��λ����
	mov al,d1
	mov bx,offset leds
	xlat 
	mov dx,io8255a
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
