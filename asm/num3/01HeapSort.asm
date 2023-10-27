include irvine32.inc

.data
arr dd 3, 1, 5, 7, 2, 4, 9, 6, 10, 8
.code
print proc
    push ebp
    mov ebp, esp
    pushad
    mov edx, [ebp + 8]
    mov ecx, [ebp + 12]
    mov esi, 0
again:
    cmp esi, ecx
    je final
    mov eax, [edx + esi * 4]
    call writeint
    mov eax, " "
    call writechar
    inc esi
    jmp again
final:
    call crlf
    popad
    mov esp, ebp
    pop ebp
    ret 8
print endp

HeapAdjust proc
    push ebp
    mov ebp, esp
    pushad
    mov edx, [ebp + 8]
    mov ecx, [ebp + 12]; s
    mov ebx, [edx + ecx * 4];tmp
    mov esi, ecx; child
    shl esi, 1
    inc esi
again:
    cmp esi, [ebp + 16]
    jge final

    mov eax, esi
    inc eax
    cmp eax, [ebp + 16]
    jge next0
    mov eax, [edx + 4 * esi + 4]
    cmp [edx + 4 * esi], eax
    jge next0
    inc esi
next0:
    mov eax, [edx + 4 * esi]
    cmp [edx + 4 * ecx], eax
    jge final
    mov [edx + 4 * ecx], eax
    mov ecx, esi
    shl esi, 1
    inc esi
    mov [edx + 4 * ecx], ebx
    jmp again

final:
    push [ebp + 16]
    push edx
    call print
    popad
    mov esp, ebp
    pop ebp
    ret 12
HeapAdjust endp

BuildHeap proc
    push ebp
    mov ebp, esp
    pushad
    mov edx, [ebp + 8]
    mov ecx, [ebp + 12]
    dec ecx
    shr ecx, 1
again:
    cmp ecx, 0
    jl final
    push [ebp + 12]
    push ecx
    push edx
    call HeapAdjust
    dec ecx
    jmp again
final:
    popad
    mov esp, ebp
    pop ebp
    ret 8
BuildHeap endp

HeapSort proc
    push ebp
    mov ebp, esp
    pushad
    mov edx, [ebp + 8]
    mov ecx, [ebp + 12]

    push ecx
    push edx
    call BuildHeap
    mov esi, ecx
    dec esi
again:
    cmp esi, 0
    jle final

    push [edx + 4 * esi]
    push [edx]
    pop [edx + 4 * esi]
    pop [edx]

    push esi
    push 0
    push edx
    call HeapAdjust

    dec esi
    jmp again
final:
    popad
    mov esp, ebp
    pop ebp
    ret 8
HeapSort endp


main proc
    push 10
    push offset arr
    call print

    push 10
    push offset arr
    call HeapSort

    push 10
    push offset arr
    call print
    ret
main endp
end main
