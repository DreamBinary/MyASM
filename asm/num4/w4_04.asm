;素数环
include irvine32.inc

.data
maxn dd 1000
vis dd 1000 dup(0)
A dd 1000 dup(0)
isp dd 1000 dup(0)
ans dd 0
n dd 0
.code

is_prime proc
    push ebp
    mov ebp, esp
    pushad
    mov ecx, [ebp + 8];x
    mov esi, 2
again:
    mov eax, esi
    mul eax
    cmp eax, ecx
    jg L1
    mov edx, 0
    mov eax, ecx
    div esi
    cmp edx, 0
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
    ret 4
is_prime endp

print proc
    pushad
    mov esi, 0
again:
    cmp esi, n
    je final
    mov eax, A[esi * 4]
    call writedec
    mov eax, " "
    call writechar
    inc esi
    jmp again
final:
    call crlf
    popad
    ret
print endp

dfs proc
    push ebp
    mov ebp, esp
    pushad
    mov ebx, [ebp + 8]; cur
    cmp ebx, n
    jne L
    mov eax, A[0]
    mov edx, n
    add eax, A[4 * edx - 4]
    cmp isp[4 * eax], 0
    je L
    inc ans
    call print
    jmp final
L:
    mov esi, 2
again:
    cmp esi, n
    jg final
    cmp vis[esi * 4], 1
    je next
    mov eax, esi
    add eax, A[ebx * 4 - 4]
    cmp isp[eax * 4], 0
    je next
    mov A[ebx * 4], esi
    mov vis[esi * 4], 1
    mov eax, ebx
    inc eax
    push eax
    call dfs
    mov vis[esi * 4], 0
next:
    inc esi
    jmp again

final:
    popad
    mov esp, ebp
    pop ebp
    ret 4
dfs endp


main proc
    call readint
    mov n, eax
    mul eax
    mov ecx, eax

    mov esi, 2
again:
    cmp esi, ecx
    jg next
    push esi
    call is_prime
    mov isp[esi * 4], eax
    inc esi
    jmp again
next:
    mov A[0], 1
    push 1
    call dfs
    mov eax, ans
    call writeint
    ret
main endp
end main