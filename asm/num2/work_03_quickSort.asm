include irvine32.inc
.data
arr dd 3, 1, 5, 7, 2, 4, 9, 6, 10, 8
.code
swap proc
    push [edx + 4 * ecx]
    push [edx + 4 * ebx]
    pop [edx + 4 * ecx]
    pop [edx + 4 * ebx]
    ret
swap endp

partition proc
    push ebp
    mov ebp, esp
    pushad
    mov edx, [ebp + 8]
    mov ebx, [ebp + 12]
    mov ecx, [ebp + 16]
    mov eax, [edx + 4 * ebx]
again:
    cmp ebx, ecx
    jge final
again1:
    cmp ebx, ecx
    jge swap1
    cmp [edx + 4 * ecx], eax
    jl swap1
    dec ecx
    jmp again1
swap1:
    call swap
again2:
    cmp ebx, ecx
    jge swap2
    cmp [edx + 4 * ebx], eax
    jg swap2
    inc ebx
    jmp again2

swap2:
    call swap

    jmp again
final:
    push 10
    push edx
    call print
    mov [ebp - 4], ebx
    popad
    mov eax, [ebp - 4]
    mov esp, ebp
    pop ebp
    ret 12
partition endp

quickSort proc
    push ebp
    mov ebp, esp
    pushad
    mov edx, [ebp + 8]
    mov ebx, [ebp + 12]
    mov ecx, [ebp + 16]
    cmp ebx, ecx
    jge final
    push ecx
    push ebx
    push edx
    call partition
    dec eax
    push eax
    push ebx
    push edx
    call quickSort
    add eax, 2
    push ecx
    push eax
    push edx
    call quickSort
final:
    popad
    mov esp, ebp
    pop ebp
    ret 12
quickSort endp

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
    mov eax, [edx + 4 * esi]
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



main proc
    push 10
    push offset arr
    call print
    push 9
    push 0
    push offset arr
    call quickSort
    push 10
    push offset arr
    call print
main endp
end main