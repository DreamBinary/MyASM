;整数拆分
include irvine32.inc
.data
res dd 10000 dup(?)
time dd 0
msg0 db "Please enter a integer N:", 0
msg1 db "there are ", 0
msg2 db " ways to divide the integer ", 0
.code

print proc
    push ebp
    mov ebp, esp
    pushad
    mov ecx, [ebp + 8]
    mov eax, time
    call writedec
    mov eax, ":"
    call writechar

    mov esi, 1
again:
    cmp esi, ecx
    je final
    mov eax, res[esi * 4]
    call writedec
    mov eax, "+"
    call writechar
    inc esi
    jmp again
final:
    mov eax, res[ecx * 4]
    call writedec
    call crlf
    popad
    mov esp, ebp
    pop ebp
    ret 4
print endp

divN proc
    push ebp
    mov ebp, esp
    pushad
    mov ecx, [ebp + 8]; n
    mov ebx, [ebp + 12]; k
    mov esi, 1

again:
    cmp esi, ecx
    jg final
    cmp esi, res[ebx * 4 - 4]
    jl next
    mov res[ebx * 4], esi
    mov eax, ecx; rest
    sub eax, esi
    cmp eax, 0
    jne L
    inc time

    push ebx
    call print

    jmp next
L:
    mov edx, ebx
    inc edx
    push edx
    push eax
    call divN

next:
    inc esi
    jmp again
final:
    popad
    mov esp, ebp
    pop ebp
    ret 8
divN endp

main proc
    mov edx, offset msg0
    call writestring
    call readint
    push 1
    push eax
    call divN
    mov ebx, eax
    mov edx, offset msg1
    call writestring
    mov eax, time
    call writedec
    mov edx, offset msg2
    call writestring
    mov eax, ebx
    call writedec
    ret
main endp
end main


