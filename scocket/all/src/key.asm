;**************************************
;* coded by CXQ
; 将矩阵键盘的键号（0－F） 在 7 段数码管上显示，按下对应的键显示对应的数字。
;**************************************
.model small
.486

PA_8255 equ 200h
PB_8255 equ 201h
PC_8255 equ 202h
ctr_8255 equ 203h

data segment	
LEDCODE db 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,
        db 7FH,67H,77H,7CH,39H,5EH,79H,71H
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
	jnz again; start
	call keyUp
	mov ax,bx
	call getKeyCode
	call disp
	call delay
	;call lightLeds;write8255PB
	jmp again
	hlt


init8255 proc
	mov dx,ctr_8255
	mov al,10001010B
	out dx,al
	ret
init8255 endp

readKey proc
	mov ah,11111110B
scan:
    mov al,ah
    mov dx,pc_8255
    out dx,al
	IN al,dx
	OR al,0FH
	CMP al,0FFH
	JNE final
	ROL ah,1
	jmp scan
final:	RET
readKey end
	
delay proc
		push cx
		mov cx,30
	X1:
		call wait4High
		call wait4Low
		LOOP X1
		POP cx
		ret
delay endp

keyUp proc 
noup:	mov al,ah
		mov dx,pc_8255
		out dx,al
		IN 	al,dx
		or al,0fh
		cmp al,0ffh
		je exit
		jmp noup
exit:	ret
keyUp	endp

getKeyCode PROC
			not ah
			not al
			mov BH,00H
			mov BL,00H
KK:			shr ah,1
			jc NEXT1
			add BH,1H
			jmp KK
NEXT1:		shr al,1
			jc NEXT2
			add BL,4
			jmp NEXT1
NEXT2:		add BH,BL
			mov al,BH
			sub al,16
CMPEXIT:	RET
getKeyCode ENDP

disp	proc
		push bx
		push dx
		mov bx,offset ledcode
		mov ah,0
		add bx,ax
		mov al,[bx]
		mov dx,pa_8255
		out dx,al
		pop dx
		pop bx
		ret
disp 	endp


wait4High proc

nextH:
	mov dx,pb_8255
	in al,dx
	test al,01h
	jz nextH
	ret
wait4High endp

wait4Low proc
nextL:
	mov dx,pb_8255
	in al,dx
	test al,01h
	jnz nextL
	ret
wait4Low endp

code ends
end start