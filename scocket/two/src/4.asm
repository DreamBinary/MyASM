
.Model small
.486

ROW equ 200h
RCOW equ 201h
GCOW equ 202h
kz_8255 equ 203h

data segment	
	ZK0 db 22h,0FAh,57h,0feh,53h,0FAh,057h,08Ah
    ZK1 db 0FFH,081H,081H,081H,081H,081H,081H,0FFH
    ZK2 db 022H,022H,0FFH,026H,0F2H,063H,062H,092H
    ZK3 db 08H,18H,28H,7FH,1CH,2AH,49H,08H
data ends

code segment
	assume cs:code,ds:data
start:
	mov ax,data
	mov ds,ax
	call init8255
again:
	call cleanDotArray
	mov di,GCOW
	mov si,0
	call displayWord0
	mov di,0
	mov si,RCOW
	call displayWord0
	mov di,GCOW
	mov si,RCOW
	call displayWord0
	call delay 
	call delay
	call cleanDotArray
	mov di,GCOW
	mov si,0
	call displayWord1
	mov di,0
	mov si,RCOW
	call displayWord1
	mov di,GCOW
	mov si,RCOW
	call displayWord1
	call delay
	call delay
	call cleanDotArray
	mov di,GCOW
	mov si,0
	call displayWord2
	mov di,0
	mov si,RCOW
	call displayWord2
	mov di,GCOW
	mov si,RCOW
	call displayWord2
	call delay
	call delay
	call cleanDotArray
	mov di,GCOW
	mov si,0
	call displayWord3
	mov di,0
	mov si,RCOW
	call displayWord3
	mov di,GCOW
	mov si,RCOW
	call displayWord3
	jmp again
	hlt
	

init8255 proc
	mov dx,kz_8255
	mov al,80h
	out dx,al
	ret
init8255 endp

cleanDotArray proc
	mov al,0
	mov dx,ROW
	out dx,al
	mov dx,GCOW
	out dx,al
	mov dx,RCOW
	out dx,al
	ret
cleanDotArray endp

displayWord0 proc
	mov cx,300h
again_0:
	mov bx, offset ZK0
	call displayWord1Times
	loop again_0
	ret
displayWord0 endp

displayWord1 proc
	mov cx,300h
again_01:
	mov bx, offset ZK1
	call displayWord1Times
	loop again_01
	ret
displayWord1 endp

displayWord2 proc
	mov cx,300h
again_02:
	mov bx, offset ZK2
	call displayWord1Times
	loop again_02
	ret
displayWord2 endp

displayWord3 proc
	mov cx,300h
again_03:
	mov bx, offset ZK3
	call displayWord1Times
	loop again_03
	ret
displayWord3 endp


displayWord1Times proc
	push cx
	mov cx,8
	mov ah,0FEh
again_1:
	mov dx,ROW
	mov al,ah
	out dx,al
	mov al,[bx]
	cmp di,0
	je next_0
	mov dx,di
	out dx,al
next_0:
	cmp si,0
	je next_1
	mov dx,si
	out dx,al
next_1:
	call delay
	mov al,0
	cmp di,0
	je next_2
	mov dx,di
	out dx,al
next_2:
	cmp si,0
	je next_3
	mov dx,si
	out dx,al
next_3:
	inc bx
	rol ah,1
	loop again_1
	pop cx
	ret
displayWord1Times endp
delay proc
	push cx
	mov cx,80h
L0:	loop L0
	pop cx
	ret
delay endp
code ends

end start
