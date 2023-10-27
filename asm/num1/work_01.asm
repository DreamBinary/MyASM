include irvine32.inc
.data
ten dd 10
.code
main proc
    mov ecx, 0
    call readint
    mov ebx, eax
again:
    cmp ebx, 0
    jle final
    mov edx, 0
    mov eax, ebx
    div ten
    mov ebx, eax

    add ecx, edx
    mov eax, ecx
    mul ten
    mov ecx, eax

    jmp again
final:
    mov eax, ecx
    div ten
    call writeint
    call crlf
    ret
main endp
end main



