delay proc
	mov bx, 10
	call setTimer ;; mode = 0
agains:
	call display
	mov dx, pc_8255
	in al, dx
	test al, 02h
	jz agains
	ret
delay endp