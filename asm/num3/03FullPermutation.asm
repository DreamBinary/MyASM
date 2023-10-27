include irvine32.inc

.data
arr dd 30 dup(?)
.code

FullPermutation proc
    push ebp
    mov ebp, esp
    pushad
    mov edx, [ebp + 8]
    mov ebx, [ebp + 12]; start
    mov ecx, [ebp + 16]; end
    cmp ebx, ecx
    jl L0
    mov esi, 0
again0:
    cmp esi, ecx
    jge endl
    mov eax, [edx + esi * 4]
    call writeint
    mov eax, " "
    call writechar
    inc esi
    jmp again0
L0:
    mov esi, ebx
again1:
    cmp esi, ecx
    jge final
    cmp ebx, esi
    je L1

    push [edx + 4  * ebx]
    push [edx + 4 * esi]
    pop [edx + 4  * ebx]
    pop [edx + 4 * esi]
L1:
    push ecx
    mov eax, ebx
    inc eax
    push eax
    push edx
    call FullPermutation

    cmp ebx, esi
    je next
    push [edx + 4  * ebx]
    push [edx + 4 * esi]
    pop [edx + 4  * ebx]
    pop [edx + 4 * esi]
next:
    inc esi
    jmp again1
endl:
   call crlf
final:
    popad
    mov esp, ebp
    pop ebp
    ret 12
FullPermutation endp

main proc
    call readint
    mov esi, 0
again:
    cmp esi, eax
    je final
    inc esi
    mov arr[esi * 4 - 4], esi
    jmp again
final:
    push eax
    push 0
    push offset arr
    call FullPermutation
    ret
main endp
end main