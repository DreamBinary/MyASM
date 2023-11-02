.model small 
.486

A0_M8259  equ  230h
A1_M8259  equ  231h
A0_S8259  equ  240h  
A1_S8259  equ  241h 
PA_8255   equ   200h
PB_8255    equ   201h
PC_8255   equ   202h
CTR_8255  equ   203h

DATA SEGMENT

LEDCODE DB 3FH,06H,5BH,4FH,66H,6DH,7DH
		DB 07H,7FH,67H 
counter db 0
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
       ;call InitS8259
       cli
       call SetINTVector
       call cleanM8259IR0Mask
       sti
 again:  
 	   call dispNumber
 	   jmp  again
                   
intHander_1s  proc  far    ;中断程序 
       call addCounter
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
       mov al, 80h;10000000b;
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

addCounter proc
	    push ax
	    push bx
		inc counter ;;counter 增大1
		xor ax,ax
		mov al,counter
		mov bl,60
		div bl ;;counter除以100
		mov counter,ah;;;ah等于余数
		pop bx
		pop ax
		ret 
addCounter endp

dispNumber proc
        xor ax,ax	
		mov al,counter
		mov bl,10
		div bl ;;counter除以10
		mov d1,al;;al等于商，故dl为counter的十位上的数；
		mov d0,ah;;ah等于余数，故d0为counter的个位上的数；
	
		mov al,d0
		mov bx,offset LEDCODE;leds
		xlat  ;;执行完该指令，al=d0的段码
		mov dx,PA_8255
		out dx,al;;将d0的段码输出A口
		mov al,01000000B;对应PC6
		mov dx,PC_8255
		out dx,al;;通过C口将PC6设置为1,点亮右边数码管，显示个位数。
		mov al,0
		out dx,al;;通过C口将PC6设置为0,熄灭右边数码管，不显示个位数。
	
		mov al,d1
		mov bx,offset LEDCODE;leds
		xlat 
		mov dx,PA_8255
		out dx,al;;将d1的段码输出A口
		mov al,10000000B;;;对应PC7
		mov dx,PC_8255
		out dx,al;;通过C口将PC7设置为1,点亮右二数码管，显示十位数。
		mov al,0
		out dx,al;通过C口将PC7设置为0,熄灭右右二数码管，不显示十位数。
		ret 
dispNumber endp 
code ends
end   start
