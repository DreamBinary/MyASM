include irvine32.inc

.data
msg1 db "YES",0
msg0 db "NO",0
.code

judge proc
    push ebp
    mov ebp, esp
    pushad
    mov ebx, [ebp + 8] ;k
    cmp ebx, [ebp + 12]
    je L1
    jg L0
    mov eax, ebx
    mov ecx, 2
    mul ecx
    inc eax
    push [ebp + 12]
    push eax
    call judge
    cmp eax, 1
    je L1
    mov eax, ebx
    mov ecx, 3
    mul ecx
    inc eax
    push [ebp + 12]
    push eax
    call judge
    cmp eax, 1
    je L1
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
judge endp


main proc
    call readint
    mov ebx, eax
    call readint
    push eax; x
    push ebx; k
    call judge
    cmp eax, 0
    je L0
    mov edx, offset msg1
    call writestring
    jmp final
L0:
    mov edx, offset msg0
    call writestring
final:
    ret
main endp
end main