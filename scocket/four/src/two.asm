.model small       
.486  ;; 486 ָ�

t0 equ 270h
tkz equ 273h

addr_0832 equ 200h
pa_8255 equ 210h
pc_8255 equ 212h 
data  segment
	nv db 153, 179, 204, 230, 243
data ends

code  segment
assume cs:code, ds:data
start:	
	mov dx, tkz
	mov al, 00110110b
	out dx, al
	mov dx, t0
	mov ax, 100
	out dx, al
	mov al, ah
	out dx, al

    mov ax, data  ;; if use data
    mov ds, ax
kk:
    mov si, 0
again:
    cmp si, 5
    jge kk
    mov dx, addr_0832
    mov al, nv[si]
    out dx, al
  	call delay3s
  	inc si
  	jmp again
  	hlt
  	
delay3s proc
	mov bx, 300
	call setTimer ;; mode = 0
again3s:
	mov dx, pc_8255
	in al, dx
	test al, 01h
	jz again3s
	ret
delay3s endp
  	
setTimer proc
	mov dx, tkz
	mov al, 00110000b
	out dx, al
	mov ax, bx
	mov dx, t0
	out dx, al
	mov al, ah
	out dx, al
	ret
setTimer endp
  	
code ends
end start
; v = n * 5 / 128 - 5
; n = 