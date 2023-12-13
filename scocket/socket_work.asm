;*********************
;* coded by fiv
;*********************
.model small
.486

PA_8255   equ  200h
PB_8255   equ  201h
PC_8255   equ  202h
CTR_8255  equ  203h

T0_8253   equ  210h
T1_8253   equ  211h
T2_8253   equ  212h
CTR_8253  equ  213h

T0_8253B   equ  220h
T1_8253B   equ  221h
T2_8253B   equ  222h
CTR_8253B  equ  223h

A0_M8259  equ  230h
A1_M8259  equ  231h
A0_S8259  equ  240h
A1_S8259  equ  241h

IN0_0809  equ  260h
IN1_0809  equ  261h
IN2_0809  equ  262h
ADDR_0832 equ  270h

data segment
    dda db 0
    ddb db 0
    ddc db 0
    nv db 153, 179, 204, 230  ; 1v, 2v, 3v, 4v
data ends

code segment
assume cs:code,ds:data
start:
    mov ax, data
    mov ds, ax

    call init8255
    call init8253
    call initM8259
    cli ; close interrupt
    call setIntVector
    call clearIRsMask
    sti ; start interrupt
again:
    hlt
    jmp again
    hlt

init8255 proc
    mov dx, CTR_8255
    mov al, 10000001b ; set 8255
    out dx, al
    ret
init8255 endp

init8253 proc
    mov dx, CTR_8253
    mov al, 00110000b ; set 8253
    out dx, al
    mov dx, T0_8253
    mov ax, 2000 ; cnt
    out dx, al
    mov al, ah
    out dx, al

    mov dx, CTR_8253
    mov al, 01110000b
    out dx, al
    mov dx, T1_8253
    mov ax, 3000 ; cnt
    out dx, al
    mov al, ah
    out dx, al

    mov dx, CTR_8253
    mov al, 11110000b
    out dx, al
    mov dx, T2_8253
    mov ax, 5000 ; cnt
    out dx, al
    mov al, ah
    out dx, al

    mov dx, CTR_8253B
    mov al, 00110000b
    out dx, al
    mov dx, T0_8253B
    mov ax, 1000 ; cnt
    out dx, al
    mov al, ah
    out dx, al
    ret
init8253 endp

initM8259 proc
    mov dx, A0_M8259 ; ICW1
    mov al, 00010011b
    out dx, al

    mov dx, A1_M8259 ; ICW2
    mov al, 00001000b ; 16 - 23
    out dx, al

    mov al, 10000000b ; ICW3
    out dx, al

    mov al, 01h ; ICW4
    out dx, al

    mov al, 0ffh ; 8259 mask
    out dx, al
    ret
initM8259 endp

setIntVector proc
    push ds
    push dx
    push ax

    mov ax, 0
    mov ds, ax

    mov si, 64 ; 4 * 16
    mov ax, offset oneHandler
    mov [si], ax
    mov ax, cs
    mov [si+2], ax

    mov si, 68
    mov ax, offset twoHandler
    mov [si], ax
    mov ax, cs
    mov [si+2], ax

    mov si, 72
    mov ax, offset threeHandler
    mov [si], ax
    mov ax, cs
    mov [si+2], ax

    mov si, 76
    mov ax, offset fourHandler
    mov [si], ax
    mov ax, cs
    mov [si+2], ax

    pop ax
    pop dx
    pop ds
    ret
setIntVector endp

clearIRsMask proc
    push dx
    mov dx, A1_M8259
    in al, dx
    and al, 11110000b ; ocw1
    out dx, al
    pop dx
    ret
clearIRsMask endp

sendM8259EOI proc
    push ax
	push dx
    mov al, 20h ; ocw2 = 0010 0000
    mov dx, A0_M8259 ; send EOI to master
    out dx, al
    pop dx
    pop ax
    ret
sendM8259EOI endp

oneHandler proc far
    push dx
    push ax
    push ds
    sti ; start interrupt
    mov ax, data
    mov ds, ax

    mov dx, IN0_0809
    call sample0809
    call getLevel
    mov dda, al

    call sendM8259EOI
    cli ; close interrupt
    pop ds
    pop ax
    pop dx
    iret ; return from interrupt
oneHandler endp

twoHandler proc far
    push dx
    push ax
    push ds
    sti ; start interrupt
    mov ax, data
    mov ds, ax

    mov dx, IN1_0809
    call sample0809
    call getLevel
    mov ddb, al

    call sendM8259EOI
    cli ; close interrupt
    pop ds
    pop ax
    pop dx
    iret ; return from interrupt
twoHandler endp

threeHandler proc far
    push dx
    push ax
    push ds
    sti ; start interrupt
    mov ax, data
    mov ds, ax

    mov dx, IN2_0809
    call sample0809
    call getLevel
    mov ddc, al

    call sendM8259EOI
    cli ; close interrupt
    pop ds
    pop ax
    pop dx
    iret ; return from interrupt
threeHandler endp

fourHandler proc far
    push dx
    push ax
    push ds
    sti ; start interrupt
    mov ax, data
    mov ds, ax

    call output

    call sendM8259EOI
    cli ; close interrupt
    pop ds
    pop ax
    pop dx
    iret ; return from interrupt
fourHandler endp

sample0809 proc
    push dx
    push ax
    ; dx -->> addr of sample0809
    ; start0809
    ; mov al, 3 ; -->> channel
    out dx, al

    ; check eoc
    push dx
    mov dx, PC_8255
agSample:
    in al, dx
    test al, 01h
    jz agSample
    pop dx

    ; dx -->> addr of sample0809
    ; read data
    in al, dx
    pop ax
    pop dx
    ret
sample0809 endp

getLevel proc
    cmp al, 1
    gl levelSmall
    cmp al, 3
    gl levelMiddle
    mov al, 3
    jmp levelFinal
levelSmall:
    mov al, 1
    jmp levelFinal
levelMiddle:
    mov al, 2
levelFinal:
    ret
getLevel endp

getMax proc
    mov al, dda
    cmp al, ddb
    jg maxNext
    mov al, ddb
maxNext:
    cmp al, ddc
    jg maxFinal
    mov al, ddc
maxFinal:
    ret
getMax endp

output proc
    push dx
    push ax

    getMax ; al -->> max
    cmp al, 1
    jne max2
    mov si, 0
    mov al, nv[si]
    call out0832
    mov al, 00000001b ; 00 (L5 - L0) b
    jmp outputFinal

max2:
    cmp al, 2
    jne max3
    mov si, 1
    mov al, nv[si]
    call out0832
    cmp ddc, 1
    jne max2Next
    mov al, 00000010b ; Dc = 1
    jmp max2Final
max2Next:
    mov al, 00100010b ; Dc = 2
max2Final:
    jmp outputFinal

max3:
    cmp al, 3
    jne outputFinal
    mov si, 2
    mov al, nv[si]
    call out0832

    cmp ddc, 1
    jne max3Next
    mov al, 00000010b ; Dc = 1
    jmp outputFinal

max3Next:
    cmp ddc, 2
    jne max3Next2
    mov al, 00100100b ; Dc = 2
    jmp outputFinal

max3Next2: ; Dc = 3
    cmp dda, 3
    je max3Next3
    cmp ddb, 3
    je max3Next3
    jmp outputFinal
max3Next3: ; Da = 3 or Db = 3
    mov al, 00111000b

outputFinal:
    call out8255A
    pop ax
    pop dx
    ret
output endp

out0832 proc
    push dx
    mov dx, ADDR_0832
    out dx, al
    pop dx
    ret
out0832 endp

out8255A proc
    push dx
    mov dx, PA_8255
    out dx, al
    pop dx
    ret
out8255A endp

code ends
end start
