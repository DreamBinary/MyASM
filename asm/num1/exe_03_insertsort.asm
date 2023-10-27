include irvine32.inc

.data
arr dd 99, 2, 3, -11, 22, 88, 7, 77, 547, 717, -54

.code

insert proc
    push ebp
    mov ebp, esp
    push ecx
    mov edx, [ebp + 8]
    mov ecx, [ebp + 12]

    mov ebx, [edx + 4 * ecx]
    mov esi, ecx
again:
    cmp [edx + 4 * esi - 4], ebx
    jle final
    mov eax, [edx + 4 * esi - 4]
    mov [edx + 4 * esi], eax
    dec esi
    cmp esi, 0
    je final
    jmp again
final:
    mov [edx + 4 * esi], ebx
    pop ecx
    mov esp,ebp
    pop ebp
    ret
insert endp

insertSort proc
    push ebp
    mov ebp, esp
    mov ecx, [ebp + 8]
    mov esi, 1
again:
    cmp esi, ecx
    jge final
    push esi
    lea eax, arr
    push eax
    call insert
    inc esi
    jmp again
final:
    mov esp, ebp
    pop ebp
    ret
insertSort endp

print proc
	mov ecx, 0
again:
    mov eax, arr[4 * ecx]
	call writeint
	mov eax, ' '
	call writechar
	inc ecx
	cmp ecx, lengthof arr
	jl again

    ret
print endp

main proc
    push lengthof arr
    call insertSort
    call print
main endp
end main



