;**************************************
;* coded by CXQ
; 试用 0832 产生 1v, 2v, 3v, 4v, 4.5v 电压，每种电压输出持续 3 秒。
;**************************************

.model small 
.486
PA_8255   equ  200h
PB_8255   equ  201h
PC_8255   equ  202h
CTR_8255  equ  203h

T0_8253   equ  210h
T1_8253   equ  211h
T2_8253   equ  212h
CTR_8253  equ  213h

A0_M8259  equ  230h
A1_M8259  equ  231h
A0_S8259  equ  240h
A1_S8259  equ  241h

IN0_0809  equ  260h
ADDR_0832 equ  270h 


data segment
	LEDCODE db 3fh,06h,5bh,4fh,66h,6dh,7dh,07h,7fh,67h
		    db 77h,7ch,39h,5eh,79h,71h
	n db ?
	high_num db ?
	low_num db ?
data ends

code segment
	assume cs:code,ds:data
start:
	mov ax,data
	mov ds,ax
	call init8255
again1:
	call delay300ms
	call start0809	
	call check0809eoc
	call read0809	
	mov n,al
	jmp again1
	hlt
	
init8255 proc
	mov dx,ctr_8255
	mov al,10000001b
	out dx,al
	ret
init8255 endp

start0809 proc
	mov dx,200h
	mov al,2
	out dx,al
	ret
start0809 endp

check0809eoc proc
again:
	call display
	mov dx,pc_8255
	in al,dx
	test al,01h
	jz again  ;=0跳again
	ret
check0809eoc endp

read0809 proc
	mov dx,in0_0809
	in al,dx
	ret
read0809 endp

delay300ms proc
	mov bx,30
	call setTimer
again300ms:
	call display
	mov dx,pc_8255
	in al,dx
	test al,2
	jz again300ms
	ret
delay300ms endp

setTimer proc
	mov dx,CTR_8253
	mov al,00110000B
	out dx,al
	mov dx,T0_8253
	mov ax,bx
	out dx,al
	mov al,ah
	out dx,al
	ret
setTimer endp

display proc
	mov bl,16
	xor dx,dx
	xor ax,ax
	mov al,n
	div bl
	mov high_num,al
	mov low_num,ah
	call writehigh
	call writelow
	ret
display endp

writehigh proc
	mov dx,pb_8255
	mov bx,0
	mov bl,high_num
	mov al,LEDCODE[bx]
	out dx,al
	mov dx,pc_8255
	mov al,10000000b
	out dx,al
	ret
writehigh endp

writelow proc
	mov dx,pb_8255
	mov bx,0
	mov bl,low_num
	mov al,led[bx]
	out dx,al
	mov dx,pc_8255
	mov al,01000000b
	out dx,al
	ret
writelow endp

code ends
end start 