include irvine32.inc

.data
arr dd 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11

.code

BiSearch proc
    push ebp
    mov ebp, esp
    pushad
    mov esi, 0; low
    mov edx, [ebp + 8]
    mov ecx, [ebp + 12]
    mov ebx, [ebp + 16]
    dec ecx; high
again:
    cmp esi, ecx
    jg L1
    mov eax, esi
    add eax, ecx
    shr eax, 1; mid
    cmp ebx, [edx + 4 * eax]
    je final
    jg L0
    dec eax
    mov ecx, eax
    jmp again
L0:
    inc eax
    mov esi, eax
    jmp again
L1:
    mov eax, -1
final:
    mov [ebp - 4], eax
    popad
    mov eax, [ebp - 4]
    mov esp, ebp
    pop ebp
    ret 12
BiSearch endp

main proc
    push 7
    push lengthof arr
    push offset arr
    call BiSearch
    call writeint
    ret
main endp
end main