;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Author:	
;comment:	Hello, World
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.Model small
.486

IO_8255 equ 0210H
PA_8255 equ IO_8255
PB_8255 equ IO_8255+1
PC_8255 equ IO_8255+2
KZ_8255 equ IO_8255+3


data segment ;数据段定义开始
	kstate db ?
data ends ;数据段定义结束   
              
                                               
code segment                            ;代码段定义结束  
	assume CS:code,DS:data
start:       
	MOV ax,data
    MOV ds,ax                    ;设置数据段的开始地址
    call init8255
re:         
	call readPA
	
	call writePB
	call delay
	jmp re

init8255 proc
	mov dx, KZ_8255
	mov al, 10010000B;
	out dx, al
	ret
init8255 endp

readPA proc
	mov dx, PA_8255
	in al, dx
	mov kstate, al
	ret
readPA endp

writePB proc
	mov al, kstate
	mov dx, PB_8255
	out dx, al
	ret
writePB endp

delay proc
	mov cx, 00ffh
next: 
	loop next
	ret
delay endp

code ends
end start


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
