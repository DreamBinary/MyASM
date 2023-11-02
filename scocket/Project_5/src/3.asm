;ʵ��˵��
;��ϵͳ�õ�������Ϊ�ж������źţ� �յ�һ���ж����� ϵͳ���������ѭ����ʾ����0,1, .. 9��

;ppluse--IRQ
;8255.cs--280h
;8255.PA0~PA7---�����a~dp
;��λ��--GROUND
;��λ��--VCC

P8259_A0 equ 200h
P8259_A1 equ 201h
P8255_A equ 210h
P8255_CTR equ 213h

data segment
	count db 0
	digits db 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH
data ends

code segment
	assume cs:code,ds:data
start:
	mov ax,data
	mov ds,ax
	call init8255
	call setIntVector
	call clearIR3Mask
	sti;�����ж�
again:	hlt
	jmp again;�ȴ����
	hlt
init8255 proc
	push dx
	mov  dx,P8255_CTR
	mov  al,10000000B;A�����
	out  dx,al
	pop  dx
init8255 endp

setIntVector proc
	push ax
	push dx
	push ds
	push si
	xor ax,ax
	mov ds,ax
	mov ax,seg lightleds
	mov si,46
	mov word ptr[si],ax
	mov ax,offset lightleds
	mov si,44
	mov word ptr[si],ax
	pop si
	pop ds
	pop dx
	pop ax
	ret
setIntVector endp

lightleds proc
	 push ds;
	 push ax
	 push bx
	 push dx
	 sti
	 mov ax,data
	 mov ds,ax

	 mov al,count
	 mov bx,offset digits
	 xlat;
	 mov dx,P8255_A
	 out dx,al
	 inc count
	 cmp count,9
	 jle next
	 mov count,0

next:	cli;���ж�
	call send8259EOI
	pop dx
	pop bx
	pop ax
	pop ds
	iret;�жϷ���
lightleds endp

send8259EOI proc
	push dx
	mov dx,P8259_A0
	mov al,00100000B;OCW2=0010 0000
	out dx,al;��8259�����жϽ���������
	pop dx
	ret
send8259EOI endp

clearIR3Mask proc
	push dx
	mov dx,P8259_A1
	in al,dx
	and al,11110111B;OCW1
	out dx,al;���IR3������λ
	pop dx
	ret
clearIR3Mask endp

code ends
end start
