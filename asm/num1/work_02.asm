include irvine32.inc

.code
main proc
    call readint
    mov ebx, eax
    call readint
    mov ecx, eax

    cmp ebx, ecx
    jge again
    xchg ebx, ecx
again:
    cmp ecx, 0
    jle final
    mov edx, 0
    mov eax, ebx
    div ecx
    mov ebx, ecx
    mov ecx, edx
    jmp again
final:
    mov eax, ebx
    call writeint
main endp
end main



