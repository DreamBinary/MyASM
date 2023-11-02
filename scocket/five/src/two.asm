; code by fiv

.model small
.486

data segment


data ends

code segment
assume cs:code, ds:data
start:
	mov ax, data
	mov ds, ax
	
	hlt
	
	
init8259 proc
	push dx
	mov dx,
init8259 endp
	
code ends
end start