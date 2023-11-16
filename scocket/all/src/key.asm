;**************************************
;* coded by fiv
; 将矩阵键盘的键号（0－F） 在 7 段数码管上显示，按下对应的键显示对应的数字
;**************************************
.model small
.486
PA_8255 equ 200H
PB_8255 equ 201H
PC_8255 equ 202H
CTRL_8255 equ 203H

data segment
	Num db ?
	digits db 3fh,06h,5BH,4fh,66h,6dh,7dh,07h,7fh,67h
		db 77h,7ch,39h,5eh,79h,71h
data ends

code segment
	assume cs:code,ds:data
start:
	mov ax,data
	mov ds,ax
	call init8255
again:
	call readKey
	mov bx,ax
	call delay
	
	call readKey
	cmp bx,ax
	jnz again
	call getKeyCode
	call OutPut
	call delay
	jmp again

init8255 proc
	mov dx,CTRL_8255
	mov al,10001010B
	out dx,al
	ret
init8255 endp

delay proc
		mov cx,30
x1:		
		call wait4high
		call wait4low
		loop x1
		ret
delay endp

wait4high proc
nexth:
		mov dx,PB_8255
		in al,dx
		test al,01h
		jz nexth
		ret
wait4high endp

wait4low proc
nextl:
		mov dx,PB_8255
		in al,dx
		test al,01h
		jnz nextl
		ret
wait4low endp

readKey proc
		mov ah,11111110B
scan:
		mov al,ah
		mov dx,PC_8255
		out dx,al
		in 	al,dx
		or 	al,0fh
		cmp al,0ffh
		jne final
		rol ah,1
		jmp scan
final:	
		ret
readKey endp

getKeyCode proc
		not ah
		not al
		mov bh,00h
		mov bl,00h
KK: 	
		shr ah,1
		jc next1
		add bh,1h
		jmp KK
next1:	
		shr al,1
		jc next2
		add bl,4
		jmp next1
next2:	
		add bh,bl
		mov al,bh
		sub al,16
		mov Num,al
cmpexit:ret
getKeyCode endp

OutPut proc
	mov dx,PA_8255
	mov bl,Num
	mov bh,0			;高4位清零
	mov al,digits[bx]
	out dx,al
	ret
OutPut endp

code ends
end start
