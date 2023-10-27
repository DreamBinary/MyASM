.model small
.486

PA_8255 equ 200h
PB_8255 equ 201h
PC_8255 equ 202h
KZ_8255 equ 203h
ROW     equ 200H
RCOW    equ 201H
GCOW    equ 202H

data segment
	ZK db 020h, 024h, 024h, 0fdh, 0adh, 0ach, 022h, 020h
data ends

code segment
	assume cs:code,ds:data
start:
	mov ax, data
	mov ds, ax
	call init8255
again:
	call cleanDotArray
	mov di, GCOW
	mov si, 0
	call displayWord
	mov di, 0
	mov si, RCOW
	call displayWord
	mov di, GCOW
	mov si, RCOW
	call displayWord
	jmp again

	hlt

init8255 proc
	mov dx, KZ_8255
	mov al, 10000000B
	out dx, al
	ret
init8255 endp

cleanDotArray proc
	mov al, 0
	mov dx, ROW
	out dx, al
	mov dx, GCOW
	out dx, al
	mov dx, RCOW
	out dx, al
	ret
cleanDotArray endp

displayWord proc
	mov cx, 300h
again_0:
	mov bx, offset ZK
	call displayWord1Times
	loop again_0
	ret
displayWord endp

displayWord1Times proc
	push cx
	mov cx, 8
	mov ah, 0FEh
again_1:
	mov dx, ROW
	mov al, ah
	out dx, al
	mov al, [bx]
	cmp di, 0
	je next_0
	mov dx, di
	out dx, al
next_0:
	cmp si, 0
	je next_1
	mov dx, si
	out dx, al
next_1:
	call delay
	mov al, 0
	cmp di, 0
	je next_2
	mov dx, di
	out dx, al
next_2:
	cmp si, 0
	je next_3
	mov dx, si
	out dx, al
next_3:
	inc bx
	rol ah, 1
	loop again_1
	pop cx
	ret
displayWord1Times endp

delay proc
	push cx
	mov cx, 80h
L0:
	loop L0
	pop cx
	ret
delay endp

code ends

end start