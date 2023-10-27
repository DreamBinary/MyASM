; PA -->> ROW
; PB -->> RCOW
; PC0 -->> 8253.out0
.Model small
.486

t0 equ 270h
tkz equ 273h

PA_8255 equ 200h
PB_8255 equ 201h
PC_8255 equ 202h
KZ_8255 equ 203h

data segment	
data ends

code segment
	assume cs:code,ds:data
start:
	mov ax,data
	mov ds,ax
	call init8255
	mov dx, PA_8255
	mov al, 0ffh
	out dx, al
	mov cx, 1000
again:

	loop again
	hlt
	

init8255 proc
	mov dx,kz_8255
	mov al,10000001b
	out dx,al
	ret
init8255 endp



code ends

end start
