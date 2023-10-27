include irvine32.inc
.data
ten dd 10
.code

reverseInt proc
    push ebp
    mov ebp, esp
    sub esp, 84
    pushad
    mov eax, [ebp + 8]
    mov ecx, 0
again1:
    cmp eax, 0
    je next
    mov edx, 0
    div ten
    mov [ebp - 84 + ecx * 4], edx
    inc ecx
    jmp again1
next:
    mov esi, 0
    mov eax, 0
again2:
    cmp esi, ecx
    je final
    mul ten
    add eax, [ebp - 84 + esi * 4]
    inc esi
    jmp again2
final:
    mov [ebp - 4], eax
    popad
    mov eax, [ebp - 4]
    add esp, 84
    mov esp, ebp
    pop ebp
    ret 4
reverseInt endp

main proc
    call readint
    push eax
    call reverseInt
    call writeint
    exit
main endp
end main



