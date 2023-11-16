;**************************************                  *
;* coded by fiv
; 试在实验箱 LED 点阵显示器上用红色循环显示“接口技术”四个字，
; 要求每个字显示 1.8秒后再显示下一个字。
;**************************************
; PA -->> ROW
; PB -->> RCOW
; PC0 -->> 8253.ouT0_8253
.Model small
.486

PA_8255 equ 200h
PB_8255 equ 201h
PC_8255 equ 202h
KZ_8255 equ 203h

T0_8253  equ 210h
CTR_8253 equ 213h

data segment
ZK  db 22h,0FFh,052h,076h, 023h,072h,052h,08Ah
    db 00H,00H,07EH,042H,081H,081H,081H,0FFH
    db 022H,022H,0FFH,026H,0F2H,063H,062H,092H
    db 08H,028H,28H,7FH,1CH,2AH,49H,08H
cnt dw 0  ;0 8 16 24 0
data ends

code segment
	assume cs:code,ds:data
start:
	mov ax,data
	mov ds,ax
	call init8255
	mov bx, offset ZK
	mov cnt, 0
	call init8253
again:
	call displayWord
	call incCnt
	mov bx, offset zk
	add bx, cnt
	jmp again
	hlt

init8255 proc
	mov dx,kz_8255
	mov al,10000001b
	out dx,al
	ret
init8255 endp

init8253 proc
	mov dx, CTR_8253
	mov al, 00110110b
	out dx, al
	mov dx, T0_8253
	mov ax, 180
	out dx, al
	mov al, ah
	out dx, al
	ret
init8253 endp

displayWord proc
next_high:
	call flashWord
	mov dx, PC_8255
	in al, dx
	test al, 1
	jnz next_high

next_low:
	call flashWord
	mov dx, PC_8255
	in al, dx
	test al, 1
	jz next_low

	ret
displayWord endp

flashWord proc
	push bx
	mov cx, 8
	mov ah, 0feh
againF:
	mov dx, PA_8255
	mov al, ah
	out dx, al
	mov al, [bx]
	mov dx, PB_8255
	out dx, al
	mov al, 00h
	out dx, al
	inc bx
	rol ah, 1 ; 循环左移一位
	loop againF
	pop bx
	ret
flashWord endp

incCnt proc
	add cnt, 8
	cmp cnt, 24
	jle next_cnt
	mov cnt, 0
next_cnt:
	ret
incCnt endp

code ends
end start
