.model small       
.486  ;; 486 ָ�
;; cs0 -->> 0809.cs
;; cs1 -->> 8255.cs

t0 equ 270h
tkz equ 273h


in3_0809 equ 203h
pa_8255 equ 210h
pb_8255 equ 211h
pc_8255 equ 212h
kz_8255 equ 213h

;pc_8255 equ 212h

data  segment
	leds DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,67H
		DB 77H,7CH,39H,5EH,79H,71H
	n	db 0
	d1	db 0
	d0	db 0
data ends

code  segment
assume cs:code, ds:data
start:	
	;mov dx, tkz
	;mov al, 00110110b
	;out dx, al
	;mov dx, t0
	;mov ax, 100
	;out dx, al
	;mov al, ah
	;out dx, al

    mov ax, data  ;; if use data
    mov ds, ax
    call init8255
again:
    call start0809 
    call check0809Eoc
   	call read0809
	mov n, al
	
	
   	call delay
    
	jmp again
  	hlt

init8255 proc
	mov dx, kz_8255
	mov al,10000001b;
	out dx, al
	ret
init8255 endp

start0809 proc
	mov al, 3
	mov dx, in3_0809
	out dx, al
	ret
start0809 endp

check0809Eoc proc
	mov dx, pc_8255
ag_check:
	in al, dx
	test al, 01h
	jz ag_check
	ret
check0809Eoc endp

read0809 proc
	mov dx, in3_0809
	in al, dx
	ret
read0809 endp

delay proc
	mov cx, 1000
agains:
	call display
	loop agains
	ret
delay endp
  	
setTimer proc
	mov dx, tkz
	mov al, 00110000b
	out dx, al
	mov ax, bx
	mov dx, t0
	out dx, al
	mov al, ah
	out dx, al
	ret
setTimer endp


display proc
  	xor ax,ax	
  	
  	mov al, n
	shl al, 4
	shr al, 4
	mov d0, al
	
	mov al,n
	shr al, 4
	mov d1, al
  	
	mov al,d0
	mov bx,offset leds
	xlat  
	mov dx,pa_8255
	out dx,al
	mov al,01000000B
	mov dx,pc_8255
	out dx,al
	mov al,0
	out dx,al
	
	mov al,d1
	mov bx,offset leds
	xlat 
	mov dx,pa_8255
	out dx,al
	mov al,10000000B
	mov dx,pc_8255
	out dx,al
	mov al,0
	out dx,al
	ret 
display endp 


code ends
end start
