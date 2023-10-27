include irvine32.inc

.data
arr dd 50 dup(0)
count dd 0
.code
isPrime proc
    push ebp
    mov ebp, esp
    pushad
    mov ecx, [ebp + 8]
    cmp ecx, 1
    je R0
    shr ecx, 1
    mov esi, 2
again:
    cmp esi, ecx
    jg R1
    mov edx, 0
    mov eax, [ebp + 8]
    div esi
    cmp edx, 0
    je R0
    inc esi
    jmp again
R0:
    mov eax, 0
    jmp final
R1:
    mov eax, 1
final:
    mov [ebp - 4], eax
    popad
    mov eax, [ebp - 4]
    mov esp, ebp
    pop ebp
    ret 4
isPrime endp

maxExp proc
    push ebp
    mov ebp, esp
    pushad
    mov eax, [ebp + 8]
    mov ecx, [ebp + 12]
    mov esi, 0; k
again:
    mov edx, 0
    div ecx
    cmp edx, 0
    jne final
    mov ebx, eax
    inc esi
    jmp again
final:
    mul ecx

    cmp esi, 0
    je final2

    mov eax, count
    mov arr[eax * 4], ecx
    mov arr[eax * 4 + 4], esi
    add count, 2
final2:
    mov [ebp - 4], ebx
    popad
    mov ebx, [ebp - 4]
    mov esp, ebp
    pop ebp
    ret 8
maxExp endp

factorNumber proc
    push ebp
    mov ebp, esp
    mov ebx, [ebp + 8]
    mov ecx, [ebp + 8]
    shr ecx, 1; n/2
    mov esi, 2
again:
    cmp esi, ecx
    jg final
    push esi
    call isPrime
    cmp eax, 0
    je next
    push esi
    push ebx
    call maxExp
next:
    inc esi
    jmp again
final:
    mov esp, ebp
    pop ebp
    ret 4
factorNumber endp

output proc
    mov ecx, 0
again:
    mov eax, arr[ecx * 4]
    call writedec
    inc ecx
    mov eax, "^"
    call writechar
    mov eax, arr[ecx * 4]
    call writedec
    inc ecx
    cmp ecx, count
    jge final
    mov eax, "*"
    call writechar
    jmp again
final:
    ret
output endp

main proc
    call readint
    push eax
    call factorNumber
    call output
main endp
end main