;九九乘法表
include irvine32.inc
.data

.code

print proc
    push ebp
    mov ebp, esp
    pushad
    mov ebx, [ebp + 8]
    mov ecx, [ebp + 12]

    mov eax, ebx
    call writedec
    mov eax, "*"
    call writechar
    mov eax, ecx
    call writedec
    mov eax, "="
    call writechar
    mov eax, ecx
    mul ebx
    call writedec

    cmp eax, 10
    jl space
    mov eax, " "
    call writechar
    jmp final
space:
    mov eax, " "
    call writechar
    mov eax, " "
    call writechar
final:
    popad
    mov esp, ebp
    pop ebp
    ret 8
print endp

row proc
    push ebp
    mov ebp, esp
    pushad
    mov ecx, [ebp + 8]
    mov esi, 1
again:
    cmp esi, 9
    jg final

    push esi
    push ecx

    call print

    inc esi
    jmp again
final:
    popad
    mov esp, ebp
    pop ebp
    ret 4
row endp

column proc
    mov esi, 1

again:
    cmp esi, 9
    jg final

    push esi
    call row
    call crlf

    inc esi
    jmp again
final:

    ret
column endp

main proc
    call column
main endp
end main
