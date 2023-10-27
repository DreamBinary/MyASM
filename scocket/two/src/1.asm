.Model small
.486

PA_8255 equ 200h
PB_8255 equ 201h
PC_8255 equ 202h
ctr_8255 equ 203h
;PB0 10KHZ
;PA0-PA7 ÊýÂë¹ÜA-G
;PC0-PC3 KL3-KL0
;PC4-PC7 KH3-KH
;BITI - K_8£¨¸ß£©
;8255CS -CS0
data segment	
LEDCODE DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,67H
		DB 77H,7CH,39H,5EH,79H,71H
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
	jnz again;START
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

readKey PROC
	mov ah,11111110B
scan:	MOV AL,AH
		MOV DX,pc_8255
		OUT DX,AL
		IN AL,DX
		OR AL,0FH
		CMP AL,0FFH
		JNE final
		ROL AH,1
		JMP scan
final:	RET
readKey ENDP
	
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
		OUT dx,al
		IN 	al,dx
		or al,0fh
		cmp al,0ffh
		je exit
		jmp noup
exit:	ret
keyUp	endp

getKeyCode PROC
			NOT AH
			NOT AL
			MOV BH,00H
			MOV BL,00H
KK:			SHR AH,1
			JC NEXT1
			ADD BH,1H
			JMP KK
NEXT1:		SHR AL,1
			JC NEXT2
			ADD BL,4
			JMP NEXT1
NEXT2:		ADD BH,BL
			MOV AL,BH
			sub al,16
CMPEXIT:	RET
getKeyCode ENDP

DISP	proc 
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
DISP 	endp


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