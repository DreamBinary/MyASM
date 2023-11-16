;**************************************
;* coded by fiv
; 将 0809 的 INT1 连接到 1 个可变电阻器上，每 1 秒采集一次 0809 转换的数字量，将
; 转换后的数字量显示在 8 段数码,用中断方式实现。
;**************************************

.model small
.486
PA_8255   equ   200h
PB_8255   equ   201h
PC_8255   equ   202h
CTR_8255  equ   203h

A0_M8259  equ  230h
A1_M8259  equ  231h
A0_S8259  equ  240h
A1_S8259  equ  241h
IN0_0809  equ  260h

DATA SEGMENT

LEDCODE DB 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,67H
		DB 77H,7CH,39H,5EH,79H,71H
n db 0
d0      db 0
d1      db 0
DATA ENDS

code segment
       assume cs:code,ds:data
start:
       mov ax,data
       mov ds,ax

       call Init8255
       call InitM8259
       call InitS8259
       cli
       call SetINTVector
       call cleanM8259IR0Mask
       sti
 again:
 	   call dispNumber
 	   jmp  again

intHander_1s  proc  far    ;中断程序
       call start0809
       call check0809Eoc
       call read0809
       call sendM8259EOI
       sti
       iret
intHander_1s  endp

sendM8259EOI proc
	   push ax
	   push dx
       mov al,20h
       mov dx, A0_M8259   ;中断结束命令
       out dx, al
       pop dx
       pop ax
       ret
sendM8259EOI endp

Init8255 proc
       mov dx, CTR_8255
       mov al,10000001b;
       out dx, al
       ret
Init8255 endp

InitM8259 proc
       MOV DX, A0_M8259     ; 主片8259 ICW1
       MOV AL, 11H
       OUT dx, AL

       MOV DX, A1_M8259     ; 8259 ICW2
       MOV AL, 16       ; VECTOR START NUM =10H(IR0)
       OUT dx, AL

       MOV AL,10000000B  ;8259 ICW3
       OUT dx,AL

       MOV AL,01H       ;8259 ICW4
       OUT dx,AL

       MOV AL,  11111111B    ;8259 MASK WORD
       OUT DX, AL
       ret
InitM8259 endp

InitS8259 proc

       MOV DX,A0_S8259    ;SLAVE 8259 ICW1
       MOV AL,11H
       OUT dx,AL

       MOV DX, A1_S8259    ; 8259 ICW2
       MOV AL, 70H            ; VECTOR START NUM =70H(从片IR0)
       OUT dx, AL

       MOV AL,07             ;8259 ICW3
       OUT dx,AL

       MOV AL,01H           ;8259 ICW4
       OUT dx,AL

       MOV AL,  11111111B    ;8259 MASK WORD
       OUT DX, AL
       ret
InitS8259    endp

SetINTVector proc
       push ds
       push ax
       push dx

	   mov ax, 0
       mov ds, ax

       mov si,64
       mov ax, offset intHander_1s
       mov [si],ax
       mov ax,cs
       mov [si+2],ax
       ;;;
       pop dx
       pop ax
       pop ds

       ret
SetINTVector endp

cleanM8259IR0Mask proc
       mov dx, A1_M8259
       in  al, dx
       and al, 11111110B
       out dx, al
       ret
cleanM8259IR0Mask endp

start0809 proc
	push ax
	push dx
	mov al, 0
	mov dx, IN0_0809
	out dx, al
	pop dx
	pop ax
	ret
start0809 endp

read0809 proc
	push dx
	push ax
	mov dx, IN0_0809
	in al, dx
	mov n, al
	pop ax
	pop dx
	ret
read0809 endp

check0809Eoc proc
	push ax
	push dx
	mov dx, pc_8255
ag_check:
	in al, dx
	test al, 01h
	jz ag_check
	pop dx
	pop ax
	ret
check0809Eoc endp

dispNumber proc
 	xor ax,ax

  	mov al, n
	shl al, 4
	shr al, 4
	mov d0, al

	mov al,n
	shr al, 4
	mov d1, al

	mov al,d0
	mov bx,offset LEDCODE
	xlat
	mov dx,PA_8255
	out dx,al
	mov al,01000000B
	mov dx,PC_8255
	out dx,al
	mov al,0
	out dx,al

	mov al,d1
	mov bx,offset LEDCODE
	xlat
	mov dx,PA_8255
	out dx,al
	mov al,10000000B
	mov dx,PC_8255
	out dx,al
	mov al,0
	out dx,al
	ret
dispNumber endp
code ends
end   start
