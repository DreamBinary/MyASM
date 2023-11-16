;**************************************
;* coded by CXQ
; parallel
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




data  segment

LEDCODE db   3fh,06h,5bh,4fh,66h
		db   6dh,7dh,07h,7fh,6fh
cnt15   db   15
cnt60   db   0
counter db   0
d0      db   0
d1      db   0
d0_15   db   0
d1_15   db   0
d0_60   db   0
d1_60   db   0
lighter db   0
data ends

code segment
       assume cs:code,ds:data
start: 	
       mov ax,data
       mov ds,ax
       
       call init8255
       call initM8259
       call initS8259
	   call init8253
       cli
       call SetINTVector
       call cleanM8259IR0Mask
       sti

 again:  
 	   call dispNumber20
 	   call dispNumber15
 	   call dispNumber60
 	   jmp  again
 	   hlt
              

init8255 proc
       mov dx, CTR_8255
       mov al, 80h;10000000b;
       out dx, al
       ret
init8255 endp

initM8259 proc
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
initM8259 endp

initS8259 proc
       MOV DX,A0_S8259    ;SLAVE 8259 ICW1
       MOV AL,11H
       OUT dx,AL 

       MOV DX, A1_S8259    ; 8259 ICW2
       MOV AL, 70H            ; VECTOR START NUM =70H(从片IR0)
       OUT dx, AL
     
       MOV AL,07h             ;8259 ICW3
       OUT dx,AL
       
       MOV AL,01H           ;8259 ICW4
       OUT dx,AL
      
       MOV AL,  11111111B    ;8259 MASK WORD
       OUT DX, AL 
       ret
initS8259    endp

init8253 proc
		mov dx, CTR_8253
		mov al, 00110110b
		out dx, al
		mov dx, T0_8253
		mov ax, 2
		out dx, al
		mov al, ah
		out dx, al
		
		mov dx, CTR_8253
		mov al, 01110110b
		out dx, al
		mov dx, T1_8253
		mov ax, 150
		out dx, al
		mov al, ah
		out dx, al
		ret
init8253 endp      
              
oneHandler  proc  far
	   push dx
	   push ax
	   push ds
	   
	   sti
	   mov ax, data
	   mov ds, ax
	   
       call showLighter
       
       call sendM8259EOI
       cli
       
       pop ds
       pop ax
       pop dx
       iret
oneHandler  endp

twoHandler  proc  far
	   push dx
	   push ax
	   push ds
	   
	   sti
	   mov ax, data
	   mov ds, ax
	   
       call addCounter
       call sendM8259EOI
       cli
       
       pop ds
       pop ax
       pop dx
       iret
twoHandler  endp

threeHandler  proc  far
	   push dx
	   push ax
	   push ds
	   
	   sti
	   mov ax, data
	   mov ds, ax
	   
       call subCnt15
       call sendM8259EOI
       cli
       
       pop ds
       pop ax
       pop dx
       iret
threeHandler  endp

fourHandler  proc  far
	   push dx
	   push ax
	   push ds
	   
	   sti
	   mov ax, data
	   mov ds, ax
	   
       call addCnt60
       call sendM8259EOI
       cli
       
       pop ds
       pop ax
       pop dx
       iret
fourHandler  endp

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

setINTVector proc
       push ds
       push ax
       push dx   
       
	   mov ax, 0
       mov ds, ax
 
       mov si,64
       mov ax, offset oneHandler
       mov [si],ax       
       mov ax,cs
       mov [si+2],ax
       
       mov si,68
       mov ax, offset twoHandler
       mov [si],ax       
       mov ax,cs
       mov [si+2],ax
       
       mov si,72
       mov ax, offset threeHandler
       mov [si],ax       
       mov ax,cs
       mov [si+2],ax
       
       mov si,76
       mov ax, offset fourHandler
       mov [si],ax       
       mov ax,cs
       mov [si+2],ax
       
       pop dx
       pop ax 
       pop ds 
       ret 
setINTVector endp  

cleanM8259IR0Mask proc
       mov dx, A1_M8259        
       in  al, dx
       and al, 10h         
       out dx, al
       ret
cleanM8259IR0Mask endp

showLighter proc
		push bx
		push ax
		push dx
		mov bl, lighter
		cmp bl, 0ffh
		jnz next_add
		mov bl, 0
		jmp show
next_add:
		shl bl, 1
		or bl, 1
show:
		mov lighter, bl
		mov al, lighter
		mov dx, PB_8255
		out dx, al
		pop dx
		pop ax
		pop bx
		ret 
showLighter endp

addCounter proc
	    push ax
	    push bx
		inc counter
		xor ax,ax
		mov al,counter
		mov bl,20
		div bl
		mov counter,ah
		pop bx
		pop ax
		ret 
addCounter endp


addCnt60 proc
	    push ax
	    push bx
		inc cnt60 
		xor ax,ax
		mov al,cnt60
		mov bl,60
		div bl
		mov cnt60,ah
		pop bx
		pop ax
		ret 
addCnt60 endp

subCnt15 proc
	    push ax
	    push bx
	    dec cnt15
	    mov al, cnt15
	    cmp al, 0
	    jnz final15
reset15:
		mov cnt15, 15
final15:
		pop bx
		pop ax
		ret 
subCnt15 endp

dispNumber20 proc
        xor ax,ax	
		mov al,counter
		mov bl,10
		div bl
		mov d1,al
		mov d0,ah
	
		mov al,d0
		mov bx,offset LEDCODE;leds
		xlat
		mov dx,PA_8255
		out dx,al
		mov al,01000000B
		mov dx,PC_8255
		out dx,al
		mov al,0
		out dx,al
	
		mov al,d1
		mov bx,offset LEDCODE;leds
		xlat 
		mov dx,PA_8255
		out dx,al
		mov al,10000000B
		mov dx,PC_8255
		out dx,al
		mov al,0
		out dx,al
		ret 
dispNumber20 endp 

dispNumber15 proc
        xor ax,ax	
		mov al,cnt15
		mov bl,10
		div bl
		mov d1_15,al
		mov d0_15,ah
	
		mov al,d0_15
		mov bx,offset LEDCODE;leds
		xlat
		mov dx,PA_8255
		out dx,al
		mov al,00010000B
		mov dx,PC_8255
		out dx,al
		mov al,0
		out dx,al
	
		mov al,d1_15
		mov bx,offset LEDCODE;leds
		xlat 
		mov dx,PA_8255
		out dx,al
		mov al,00100000B
		mov dx,PC_8255
		out dx,al
		mov al,0
		out dx,al
		ret 
dispNumber15 endp 


dispNumber60 proc
        xor ax,ax	
		mov al,cnt60
		mov bl,10
		div bl
		mov d1_60,al
		mov d0_60,ah
	
		mov al,d0_60
		mov bx,offset LEDCODE;leds
		xlat
		mov dx,PA_8255
		out dx,al
		mov al,00000100B
		mov dx,PC_8255
		out dx,al
		mov al,0
		out dx,al
	
		mov al,d1_60
		mov bx,offset LEDCODE
		xlat 
		mov dx,PA_8255
		out dx,al
		mov al,00001000B
		mov dx,PC_8255
		out dx,al
		mov al,0
		out dx,al
		ret 
dispNumber60 endp 


code ends
end start
