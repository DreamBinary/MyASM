include irvine32.inc

.data
arr db 50 dup(?)
ten db 10
sys db '0'
.code

compute proc
    pushad
    mov cl, 0
    mov esi, 0
again:
    cmp arr[esi], 0
    je final
    mov al, arr[esi]
    call isdigit
    jne move
    mov bl, al
    sub bl, '0'
    mov al, cl
    mul ten
    add al, bl
    mov cl, al
next:
    inc esi
    jmp again
move:
    mov sys, al
    mov dl, cl
    mov cl, 0
    jmp next
final:
    mov al, dl
    cmp sys, '+'
    je L0
    cmp sys, '-'
    je L1
    cmp sys, '*'
    je L2
    cmp sys, '/'
    je L3
L0:
    add al, cl
    jmp print
L1:
    sub al, cl
    jmp print
L2:
    mul cl
    jmp print
L3:
    div cl
    jmp print
print:
    call writeint
    popad
    ret
compute endp

main proc
    mov edx, offset arr
    mov ecx, lengthof arr
    call readstring
    call compute
;    call writestring
    ret
main endp
end main