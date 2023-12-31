;5、试在实验箱上设计一个系统，该系统每 100 毫秒采样试验箱中一个直流电源
;的电压，并将所得电压值显示在 8 段数码上。
;cs0-0809.cs
;cs1-8255.cs
;cs6-8253.cs
;8253.out0-8255.pc1
;8253.clk0-100hz
;8253.gate0-k1(1)
;8255.pb6~pb0-gfedcba
;8255.pc0-0809.eoc
;8255.pc6--bit1
;8255.pc7--bit2
;0809.clk-100khz
;vout1-0809.int0
; S1: q= n /51;
; r=n % 51;
; S2: m1=r / 5;
; m2= r % 5
; S3: if m2 >=3 then s=m1 +1;
; else s=m1
; S4: U= q.s
.model small 
.486
in0_0809 equ 200h
pa_8255 equ 210h
pb_8255 equ 211h
pc_8255 equ 212h
ctr_8255 equ 213h
T0_8253 equ 260h  
KZ_8253 equ 263h

data segment
	led db 3fh,06h,5bh,4fh,66h,6dh,7dh,07h,7fh,67h
	n db ?
	q db ?
	r db ?
	s db ?
	m1 db ?
	m2 db ?
data ends

code segment
	assume cs:code,ds:data
start:
	mov ax,data
	mov ds,ax
	call init8255
again1:
	call start0809
	call check0809eoc
	call read0809	
	mov n,al
	call delay100ms
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
	mov dx,pc_8255
	in al,dx
	test al,01h
	jz again
	ret
check0809eoc endp

read0809 proc
	mov dx,in0_0809
	in al,dx
	ret
read0809 endp

delay100ms proc
	mov bx,10
	call setTimer
	call suanfa
again100ms:
	call display
	mov dx,pc_8255
	in al,dx
	test al,2
	jz again100ms
	ret
delay100ms endp

setTimer proc
	mov dx,kz_8253
	mov al,00110000B
	out dx,al
	mov dx,T0_8253
	mov ax,bx
	out dx,al
	mov al,ah
	out dx,al
	ret
setTimer endp

suanfa proc
s1:	mov al,n
	mov bl,51
	div bl
	mov q,al
	mov r,ah
s2:	xor ax,ax
	mov al,r
	mov bl,5
	div bl
	mov m1,al
	mov m2,ah
s3:	cmp m2,3
	jb L1
	inc al
	mov s,al
	jmp final
L1:
	mov s,al
final: 
	ret
suanfa endp

display proc
	call writehigh
	call writelow
	ret 
display endp

writehigh proc
	mov dx,pb_8255
	mov bx,0
	mov bl,q
	mov al,led[bx]
	or al,80h;;显示小数点的
	out dx,al
	mov dx,pc_8255
	mov al,10000000b
	out dx,al
	mov al,0
	out dx,al
	ret
writehigh endp

writelow proc
	mov dx,pb_8255
	mov bx,0
	mov bl,s
	mov al,led[bx]
	out dx,al
	mov dx,pc_8255
	mov al,01000000b
	out dx,al
	mov al,0
	out dx,al
	ret
writelow endp

code ends
end start 