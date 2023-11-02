;实验说明
;用中断方式实现倒计时60s， 并将剩余时间显示在数码管上

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
PO809_INO equ 260h
data segment
	U db 0
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
	sti;开放中断
again:
    call displayUIn8Leds
    jmp again;等待完成
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

displayUIn8Leds proc
    push dx
    xor ax, ax
    mov al, u;
    mov bl,16;!!!
    div bl
    mov bx, offset digits
    xlat
    mov dx,P8255_A
    out dx, al
    mov dx,P8255_C
    mov al,00000010B;pc1=1
    out dx, al
    mov al,0
    out dx, al
    mov al, ah
    xlat;
    mov dx,P8255_A
    out dx, al
    mov dx,P8255_C
    mov al,00000001B;pc0=1
    out dx, al
    mov al,0
    out dx, al
    pop dx
    ret
displayUIn8Leds endp

readData proc
    push ds ;保护现场
    push ax
    push bx
    push dx
    sti;开放中断，允许响应更高级中断
    mov ax, data
    mov ds, ax;在中断服务程序中重新装载DS寄存器
    mov dx,PO809_INO
    out dx, al;启动0809转换INO的电压
    mov dx,P8255_C
    next: in al, dx
    test al,00000100B;
    jz next;wait4EOC
    mov dx,PO809_INO
    in al, dx;读0809转换INO的电压
    mov U, al
    cli ;关闭中断，准备中断返回
    call send8259EOI
    pop dx;恢复现场
    pop bx
    pop ax
    pop ds
    iret;中断返回
readData endp

init8255 proc
	push dx
	push ax
	mov  dx,P8255_CTR
	mov  al,10000000B;A口輸出
	out  dx,al
	pop  ax
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
	mov ax,offset readData
	mov [si],ax
	mov ax,cs
	mov [si+2],ax
	
	pop si
	pop ds
	pop dx
	pop ax
	ret
setIntVector endp

send8259EOI proc
	push ax
	push dx

	mov dx,a0_M8259
	mov al,00100000B;OCW2=0010 0000
	out dx,al;向8259发送中断结束的命令

	pop dx
	pop ax
	ret
send8259EOI endp

clearIR3Mask proc
	push dx
	push ax
	
	mov dx,A1_M8259
	in al,dx
	and al,11111010B;OCW1
	out dx,al;清除IR3的屏蔽位
	
	pop ax
	pop dx
	ret
clearIR3Mask endp

code ends
end start
