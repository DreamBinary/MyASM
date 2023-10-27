.model small
.486

PA_8255 equ 200h
PB_8255 equ 201h
PC_8255 equ 202h
KZ_8255 equ 203h
FLAG    equ 0FFh
GREEN_NS equ 24h
GREEN_EW equ 81h

data segment
	states db 24h, 44h, 04h, 44h, 04h, 44h, 04h
		   db 81h, 82h, 80h, 82h, 80h, 82h, 80h
		   db 0ffh
data ends

code segment
	assume cs:code,ds:data
start:
	mov ax, data
	mov ds, ax
	call init8255
again:
	mov si, 0
nextstate:
	mov al, states[si]
	cmp al, FLAG
	jz again
	mov dx, PA_8255
	out dx, al
	inc si
	cmp al, GREEN_NS
	jz longDelay
	cmp al, GREEN_EW
	jz longDelay
	call delay2s
	jmp next
longDelay:
	call delay30s
next:
	jmp nextstate
	hlt
	


delay30s proc
	mov cx, 10
again_30s:
	call wait4High
	call wait4Low
	loop again_30s
	ret
delay30s endp

delay2s proc
	mov cx, 1
again_2s:
	call wait4High
	call wait4Low
	loop again_2s
	ret
delay2s endp

init8255 proc
	mov dx, KZ_8255
	mov al, 10000001B
	out dx, al
	ret
init8255 endp

wait4High proc
nexth:
	mov dx, PC_8255
	in al, dx
	test al, 01h
	jz nexth
	ret
wait4High endp

wait4Low proc
nextl:
	mov dx, PC_8255
	in al, dx
	test al, 01h
	jnz nextl
	ret
wait4Low endp


code ends

end start