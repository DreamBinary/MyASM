include irvine32.inc

.data
queen dd 8 dup(?)
count dd 0
.code

check proc
    push ebp
    mov ebp, esp
    pushad
    mov ecx, [ebp + 8];line
    mov ebx, [ebp + 12];list
    mov esi, 0
again:
    cmp esi, ecx
    je L1
    mov eax, queen[4 * esi];data
    cmp ebx, eax
    je L0
    add eax, esi
    mov edx, ebx
    add edx, ecx
    cmp eax, edx
    je L0
    sub eax, esi
    sub eax, esi
    sub edx, ecx
    sub edx, ecx
    cmp eax, edx
    je L0
    inc esi
    jmp again
L0:
    mov eax, 0
    jmp final
L1:
    mov eax, 1
final:
    mov [ebp - 4], eax
    popad
    mov eax, [ebp - 4]
    mov esp, ebp
    pop ebp
    ret 8
check endp

print proc
    pushad
    mov ecx, 0
again0:
    cmp ecx, 8
    je final

    mov esi, 0
again1:
    cmp esi, queen[ecx * 4]
    je L1
    mov eax, "0"
    call writechar
    inc esi
    jmp again1
L1:
    mov eax, "#"
    call writechar

    mov esi, queen[ecx * 4]
    inc esi
again2:
    cmp esi, 8
    je L2
    mov eax, "0"
    call writechar
    inc esi
    jmp again2
L2:
    call crlf

    inc ecx
    jmp again0

final:
    mov esi, 0
again3:
    cmp esi, 10
    je endl
    mov eax, "="
    call writechar
    inc esi
    jmp again3
endl:
    call crlf
    popad
    ret
print endp


eight_queen proc
    push ebp
    mov ebp, esp
    pushad
    mov ebx, [ebp + 8]; line

    mov esi, 0
again:
    cmp esi, 8
    je final

    push esi
    push ebx
    call check
    cmp eax, 0
    je next
    mov queen[4 * ebx], esi

    cmp ebx, 7
    jne L
    inc count
    call print
    mov queen[4 *ebx], 0
    jmp final

L:
    mov eax, ebx
    inc eax
    push eax
    call eight_queen
    mov queen[4 * ebx], 0

next:
    inc esi
    jmp again

final:
    popad
    mov esp, ebp
    pop ebp
    ret 4
eight_queen endp

main proc
;    call print
    push 0
    call eight_queen
    mov eax, count
    call writeint
    ret
main endp
end main