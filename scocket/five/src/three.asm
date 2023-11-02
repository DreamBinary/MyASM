; code by fiv

.model small
.486

A0_M8259 equ 230h
A1_M8259 equ 231h

A0_S8259 equ 240h
A1_S8259 equ 241h

pa_8255 equ 210h
pb_8255 equ 211h
pc_8255 equ 212h
kz_8255 equ 213h

data segment
leds DB 3FH,06H,5BH,4FH,66H,6DH,7DH
		DB 07H,7FH,67H 
	counter db 0
	d0 db 0
	d1 db 0
data ends

code segment
assume cs:code, ds:data
start:
	mov ax, data
	mov ds, ax
	
	call init8255
	call initM8259
	call initS8259
	cli
	call setIntVector
	sti
again:
	call display
	jmp again
	hlt
	
init8255 proc
	mov dx, kz_8255
	mov al,10000001b;
	out dx, al
	ret
init8255 endp
	
initM8259 proc
	mov dx, A0_M8259 ;icw1
	mov al, 11h
	out dx, al
	
	mov dx, A1_M8259 ;icw2
	mov al, 16h
	out dx, al
	
	mov al, 80h ;icw3
	out dx, al
	
	mov al, 01h ;icw4
	out dx, al
	
	mov al, 11111111b ; 8259 mask word
	out dx, al
	
	ret
initM8259 endp

initS8259 proc
	mov dx, A0_S8259 ;icw1
	mov al, 11h
	out dx, al
	
	mov dx, A1_S8259 ;icw2
	mov al, 70h
	out dx, al
	
	mov al, 07h ;icw3
	out dx, al
	
	mov al, 01h ;icw4
	out dx, al
	
	mov al, 11111111b ; 8259 mask word
	out dx, al
	
	ret
initS8259 endp

addCnt proc
	push ax
	push bx
	
	inc counter
	xor ax, ax
	mov al, counter
	mov bl, 60
	div bl
	mov counter, ah
	
	pop bx
	pop ax
	ret
addCnt endp


sendM8259EOI proc
	push ax
	push dx
	mov al, 20h
	mov dx, A0_M8259 ;中断结束命令
	out dx, al
	pop dx
	pop ax
sendM8259EOI endp

intHandle_1s proc far
	call addCnt
	call sendM8259EOI
	sti
	iret
intHandle_1s endp

setIntVector proc
	push dx
	push ax
	push dx
	mov ax, 0
	mov dx, ax
	
	; set interrupt vector
	mov si, 64  ;; ?
	mov ax, offset intHandle_1s
	mov [si], ax
	mov ax, cs
	mov [si + 2], ax ; 67
	
	
	mov dx, A1_M8259
	in al, dx ; read
	and al, 11111110b ; rm IRQ0
	out dx, al
	
	pop dx 
	pop ax 
	pop dx
	ret
setIntVector endp


display proc
    xor ax,ax	
	mov al,counter
	mov bl,10
	div bl ;;counter除以10
	mov d1,al;;al等于商，故dl为counter的十位上的数；
	mov d0,ah;;ah等于余数，故d0为counter的个位上的数；
	
	mov al,d0
	mov bx,offset leds
	xlat  ;;执行完该指令，al=d0的段码
	mov dx,pa_8255
	out dx,al;;将d0的段码输出A口
	mov al,01000000B;对应PC6
	mov dx,pc_8255
	out dx,al;;通过C口将PC6设置为1,点亮右边数码管，显示个位数。
	mov al,0
	out dx,al;;通过C口将PC6设置为0,熄灭右边数码管，不显示个位数。
	mov al,d1
	mov bx,offset leds
	xlat 
	mov dx,pa_8255
	out dx,al;;将d1的段码输出A口
	mov al,10000000B;;;对应PC7
	mov dx,pc_8255
	out dx,al;;通过C口将PC7设置为1,点亮右二数码管，显示十位数。
	mov al,0
	out dx,al;;通过C口将PC7设置为0,熄灭右右二数码管，不显示十位数。
	ret 
display endp 
	
code ends
end start