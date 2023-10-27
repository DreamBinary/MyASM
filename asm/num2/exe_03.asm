include irvine32.inc

.data
arr dd 99, 2, 3, -1, 22, -88, 7, -77, 54

.code
insertSortArray proc
    push ebp
    mov ebp, esp
    mov edx, [ebp + 8]
    mov ecx, [ebp + 12]
    mov esi, 1
again1:
    cmp esi, ecx
    jge final
    mov ebx, [edx + esi * 4]; temp
    mov edi, esi; j
    dec edi
again2:
    cmp edi, 0
    jl next
    cmp [edx + edi * 4], ebx
    jle next
    mov eax, [edx + edi * 4]
    mov [edx + edi * 4 + 4], eax
    dec edi
    jmp again2
next:
    mov [edx + edi * 4 + 4], ebx
    inc esi
    jmp again1
final:
    mov esp, ebp
    pop ebp
    ret 8
insertSortArray endp

output proc
    mov ecx, 0
again:
    cmp ecx, lengthof arr
    jge final
    mov eax, arr[ecx * 4]
    call writeint
    call crlf
    inc ecx
    jmp again
final:
    ret
output endp

main proc
    push lengthof arr
    push offset arr
    call insertSortArray
    call output
main endp
end main