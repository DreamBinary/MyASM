include irvine32.inc

.data
arr dd 99, 2, 3, -11, 22, 88, 7, 77, 547, 717, -54
.code

maxIndex proc
	mov ebx, 0
	mov esi, 0
again:
	cmp esi, ecx
	jge final
	mov eax, [edx + 4 * ebx]
	cmp eax, [edx + 4 * esi]
	jl change
	inc esi
	jmp again
change:
    mov ebx, esi
    inc esi
    jmp again
final:
	ret
maxIndex endp

selectSort proc
	mov ecx, lengthof arr
again:
    cmp ecx, 1
	jle final
	call maxIndex
	push [edx + 4 * ebx]
	push [edx + 4 * ecx - 4]
	pop [edx + 4 * ebx]
	pop [edx + 4 * ecx - 4]
	dec ecx
	jmp again
final:
	ret
selectSort endp

print proc
	mov ecx, 0
again:
    mov eax, [edx + 4 * ecx]
	call writeint
	mov eax, ' '
	call writechar
	inc ecx
	cmp ecx, lengthof arr
	jl again

    ret
print endp

main proc
	mov edx, offset arr
	call selectSort
	call print
main endp
end main
