.model small       
.486  ;; 486 ָ�

addr_0832 equ 200h

data  segment
	n_1v db 153
data ends

code  segment
assume cs:code, ds:data
start:	
    mov ax, data  ;; if use data
    mov ds, ax
    mov dx, addr_0832
    mov al, n_1v
    out dx, al
  	hlt
code ends
end start
; v = n * 5 / 128 - 5
; n = 