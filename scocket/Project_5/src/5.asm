;ʵ��˵��
;���жϷ�ʽʵ�ֵ���ʱ60s�� ����ʣ��ʱ����ʾ���������

;8253.out1--IRQ
;8253.cs--290h
;8253.clk0--1MHZ
;8253.gate0--vcc
;8253.gate1--vcc
;8253.out0--8253.clk1
;8255.cs--280h
;8255.PA0~PA7---a~dp
;8255.pc0--s0
;8255.pc1--s1


a0_M8259 equ 200h
a1_M8259 equ 201h
a0_s8259 equ 220h
a1_s8259 equ 221h

P8255_A equ 210h
P8255_C equ 212h
P8255_CTR equ 213h

P8253_T0 equ 260h
P8253_T1 equ 261h
P8253_CTR equ 263h

data segment
	count db 60
	digits db 3FH,06H,5BH,4FH,66H,6DH,7DH,07H,7FH,6FH
data ends

code segment
	assume cs:code,ds:data
start:
	mov ax,data
	mov ds,ax
	call init8255
	call initm8259
	call inits8259
	cli
	call setIntVector
	call clearIR3Mask
	sti;�����ж�
again:	
	call dispalyTime
	jmp again;�ȴ����
	hlt
	
initm8259 proc
	mov dx,a0_M8259
	mov al,11H
	out dx,al
	
	mov dx,a1_M8259
	mov al,16
	out dx,al
	
	mov al,80h
	out dx,al
	
	mov al,01h
	out dx,al
	
	mov al,11111111B
	out dx,al
	
	ret
initm8259 endp

inits8259 proc
	mov dx,a0_s8259
	mov al,11H
	out dx,al
	
	mov dx,a1_s8259
	mov al,70h
	out dx,al
	
	mov al,07h
	out dx,al
	
	mov al,01h
	out dx,al
	
	mov al,11111111B
	out dx,al	
	ret
inits8259 endp

dispalyTime proc;ax =53
	push dx
	push bx
	push ax

	xor ax,ax
	mov al,count;ax = 53
	mov bl,10
	div bl;ah = 3, al =5
	mov bx, offset digits

	xlat;al = 5 ����
	mov dx,P8255_A
	out dx,al
	mov dx,P8255_C
	mov al,00000010B;pc1
	out dx,al;����������
	mov al,0
	out dx,al;����������
	
	mov al,ah
	xlat;al = 5 ����
	mov dx,P8255_A
	out dx,al
	mov dx,P8255_C
	mov al,00000001B;pc0
	out dx,al;�ұ��������
	mov al,0
	out dx,al;�ұ��������

	pop ax
	pop bx
	pop dx
	ret
dispalyTime endp

init8255 proc
	push dx
	mov  dx,P8255_CTR
	mov  al,10000000B;A��ݔ��
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
	
	mov si,72
	mov ax,offset lightleds
	mov [si],ax
	mov ax,cs
	mov [si+2],ax
	
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
	push ax
	push dx

	mov dx,a0_M8259
	mov al,00100000B;OCW2=0010 0000
	out dx,al;��8259�����жϽ���������

	pop dx
	pop ax
	ret
send8259EOI endp

clearIR3Mask proc
	push dx

	mov dx,A1_M8259
	in al,dx
	and al,11111010B;OCW1
	out dx,al;���IR3������λ

	pop dx
	ret
clearIR3Mask endp

code ends
end start
