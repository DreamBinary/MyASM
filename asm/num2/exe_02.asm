include irvine32.inc
.data
two dd 2
.code
isPerfNumber proc
    push ebp
    mov ebp, esp
    pushad
    mov ebx, 1; sum
    mov ecx, 2; factor
again:
    mov eax, [ebp + 8]
    shr eax, 1
    cmp ecx, eax
    jg final

    mov eax, [ebp + 8]
    mov edx, 0
    div ecx
    cmp edx, 0
    jne next
    add ebx, ecx
next:
    inc ecx
    jmp again

final:
    cmp ebx, [ebp + 8]
    je L0
    mov eax, 0
    mov [ebp - 4], eax
    jmp L1
L0:
    mov eax, 1
    mov [ebp - 4], eax
L1:
    popad
    mov eax, [ebp - 4]
    mov esp, ebp
    pop ebp
    ret 4
isPerfNumber endp


printPerfNumbers proc
    push ebp
    mov ebp, esp
    mov edx, [ebp + 8]
    mov ecx, 0;count
    mov esi, 6;n
again:
    cmp ecx, edx
    je final

    push esi
    call isPerfNumber
    cmp eax, 0
    je next
    mov eax, esi
    call writeint
    call crlf
    inc ecx
next:
    inc esi
    jmp again
final:
    mov esp, ebp
    pop ebp
    ret 4
printPerfNumbers endp


main proc
    call readint
    push eax
    call printPerfNumbers
main endp
end main



