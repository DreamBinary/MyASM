.Model small
.486

t0 equ 270h
tkz equ 273h

PA_8255 equ 200h
PC_8255 equ 202h
CTR_8255 equ 203h
FLAG equ 0FFh
GREEN_NS equ 24h
GREEN_EW equ 81h
data segment	
	states db 24h,44h,04h,44h,04h,44h,04h
		   db 81h,82h,80h,82h,80h,82h,80h
		   db 0ffh
data ends

code segment
	assume cs:code,ds:data
start:
	mov dx, tkz
	mov al, 00110110b
	out dx, al
	mov dx, t0
	mov ax, 100
	out dx, al
	mov al, ah
	out dx, al
	
	
	mov ax,data
	mov ds,ax
	call init8255
again:
	mov si,0
nextstate:
	mov al,states[si]
	cmp al,FLAG
	jz again
	mov dx,PA_8255
	out dx,al
	inc si
	cmp al,GREEN_NS
	jz longDelay
	cmp al,GREEN_EW
	jz longDelay
	call delay1s
	jmp next
longDelay:
	call delay1s
next: 
	jz nextstate
	hlt
	
delay10s proc
	mov bx, 1000
	call setTimer ; T0 -->> mode = 0, init cnt = 1000  <<-- 100Hz
again_10s:
	mov dx, PC_8255
	in al, dx
	test al, 1
	jz again_10s
	ret
delay10s endp

delay1s proc
	mov bx, 100
	call setTimer ; T0 -->> mode = 0, init cnt = 100  <<-- 100Hz
again_1s:
	mov dx, PC_8255
	in al, dx
	test al, 1
	jz again_1s
	ret
delay1s endp

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

init8255 proc
	mov dx,CTR_8255
	mov al,10000001B
	out dx,al
	ret
init8255 endp

code ends

end start
