;迷宫
include irvine32.inc

.data
row dd 9
maze dd 2,2,2,2,2,2,2,2,2
     dd 2,0,0,0,0,0,0,0,2
     dd 2,0,2,2,0,2,2,0,2
     dd 2,0,2,0,0,2,0,0,2
     dd 2,0,2,0,2,0,2,0,2
     dd 2,0,0,0,0,0,2,0,2
     dd 2,2,0,2,2,0,2,2,2
     dd 2,0,0,0,0,0,0,0,2
     dd 2,2,2,2,2,2,2,2,2

msg0 db "显示迷宫：", 0
M dd 9
start1 dd 1
start2 dd 1
end1 dd 7
end2 dd 7
.code

visit proc
    push ebp
    mov ebp, esp
    pushad
    mov ebx, [ebp + 8]; i
    mov ecx, [ebp + 12]; j

    mov eax, ebx
    mul row
    add eax, ecx
    mov maze[eax * 4], 1

    cmp ebx, end1
    jne next0
    cmp ecx, end2
    jne next0
    call print2

next0:
    mov eax, ebx
    mul row
    add eax, ecx
    inc eax

    cmp maze[eax * 4], 0
    jne next1

    mov eax, ecx
    inc eax
    push eax
    push ebx
    call visit
next1:
    mov eax, ebx
    inc eax
    mul row
    add eax, ecx

    cmp maze[eax * 4], 0
    jne next2

    mov eax, ebx
    inc eax
    push ecx
    push eax
    call visit
next2:
    mov eax, ebx
    mul row
    add eax, ecx
    dec eax

    cmp maze[eax * 4], 0
    jne next3

    mov eax, ecx
    dec eax
    push eax
    push ebx
    call visit
next3:
    mov eax, ebx
    dec eax
    mul row
    add eax, ecx

    cmp maze[eax * 4], 0
    jne final

    mov eax, ebx
    dec eax
    push ecx
    push eax
    call visit

final:
    mov eax, ebx
    mul row
    add eax, ecx
    mov maze[eax * 4], 0
    popad
    mov esp, ebp
    pop ebp
    ret 8
visit endp

print2 proc
    pushad
    mov edx, offset msg0
    call writestring
    call crlf
    mov ecx, 0
again0:
    cmp ecx, M
    je final

    mov esi, 0
again1:
    cmp esi, M
    je next0

    mov eax, ecx
    mul row
    add eax, esi
    mov eax, maze[eax * 4]
    cmp eax, 2
    je L0
    cmp eax, 1
    je L1
    mov eax, " "
    call writechar
    jmp next1
L0:
    mov eax, "o"
    call writechar
    jmp next1
L1:
    mov eax, "."
    call writechar
next1:
    inc esi
    jmp again1

next0:
    call crlf
    inc ecx
    jmp again0

final:
    popad
    ret
print2 endp

print proc
    pushad
    mov edx, offset msg0
    call writestring
    call crlf
    mov ecx, 0
again0:
    cmp ecx, M
    je final

    mov esi, 0
again1:
    cmp esi, M
    je next0

    mov eax, ecx
    mul row
    add eax, esi
    mov eax, maze[eax * 4]
    cmp eax, 2
    jne space
    mov eax, "o"
    call writechar
    jmp next1
space:
    mov eax, " "
    call writechar
next1:
    inc esi
    jmp again1

next0:
    call crlf
    inc ecx
    jmp again0

final:
    popad
    ret
print endp

main proc
    call print
    push start2
    push start1
    call visit
    ret
main endp
end main