.model small
.486
pa_8255 EQU 0200H
pb_8255 EQU 0201H
pc_8255 EQU 0202H
ctr_8255 EQU 0203H
FLAG EQU 0ffh

GREEN_NS EQU 024h
GREEN_WE EQU 081h
;PB �����A-G
;pA ��
;BITI - K_8���ߣ�\
; pc0 1HZ
datas	segment

states  db 24h, 44h, 04h, 44h, 04h, 44h, 04h ; �����ƿ���
        db 81h, 82h, 80h, 82h, 80h, 82h, 80h ; ��״̬����
        db 0ffh    ; һ�ֽ�����־
digits	db 3fh,06h,5BH,4fh,66h,6dh,7dh,07h,7fh,67h
		db 77h,7ch,39h,5eh,79h,71h
		
datas	ends

codes	segment
		assume cs:codes,ds:datas
start:
		mov ax,datas
		mov ds,ax
		CALL Init_8255 ;��ʼ��8255
again:	
		mov si,0
next:
		mov al,states[si]
		cmp al,FLAG
		
		jz again 
		
		mov dx, pa_8255
	    out dx, al     ;�����Ӧ��״̬
	    inc si
	    
	    cmp al,GREEN_NS
	    jz call1

		cmp al,GREEN_WE
		jz call1
		
	
		call delay1
		jmp next
call1:
		call delay30
		call delay1
		jmp next
		
Init_8255 PROC
   		MOV DX,ctr_8255 ;8255��ʽ�ֿ����ֿ��ƣ�10011000
    	MOV AL,10000001b ;A�ڷ�ʽ0 ���,B�ڷ�ʽ C���°������,
    	OUT DX,AL
    	RET
Init_8255 ENDP

delay1 proc
	
	call wait4high
	call wait4low
	mov al,00h
	mov dx,pb_8255
	out dx,al
	ret
delay1 endp

delay30 proc
		push cx
		
		mov cx,5
x1:		
		mov bx,offset digits
		mov ch,0
		add bx,cx
		mov al,[bx]
		mov dx,pb_8255
		out dx,al
		call wait4high
		call wait4low
		loop x1
		
		pop cx
		ret
delay30 endp

wait4high proc
nexth:
		mov dx,pc_8255
		in al,dx
		test al,01h
		jz nexth
		ret
wait4high endp

wait4low proc
nextl:
		mov dx,pc_8255
		in al,dx
		test al,01h
		jnz nextl
		ret
wait4low endp

codes	ends
end start
