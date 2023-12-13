;*********************
;* coded by fiv
;*********************
; 74138.CS0 -->> 8255.CS
; 74138.CS1 -->> 8253.CS
; 74138.CS3 -->> 8259M.CS
; 74138.CS4 -->> 8259S.CS
; 74138.CS6 -->> 0809.CS
; 74138.CS7 -->> 0832.CS

; 8255.PC0 -->> 0809.EOC
; 8255 other

; 8253.CLK0 -->> ?HZ
; 8253.GATE0 -->> VCC
; 8253.OUT0 -->> ?  ; clk

; 8259.INT -->> INT
; 8259.INTA -->> INTA
; 8259.IR0 -->> ?  ; clk

; 0809.EOC -->> 8255.PC0
; 0809.IN0 -->> ?  ; input
; 0809.IN7 -->> ?  ; input

; 0832.OUT -->> ?
; 0832.ILE -->> VCC

; pseudocode
; 8253 produce clk to IRs
; if (IR0) {
;   ...
; }
; if (IR1) {
;   ...
; }

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

A0_M8259  equ  230h
A1_M8259  equ  231h
A0_S8259  equ  240h
A1_S8259  equ  241h

IN0_0809  equ  260h
IN7_0809  equ  267h
ADDR_0832 equ  270h

data segment
    fiv   db ?
    fivv  db ?
data ends

code segment
assume cs:code,ds:data
start:
    mov ax, data
    mov ds, ax

    call init8255
    call init8253
    call initM8259
    ; call initS8259
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
    mov al, 10000000b ; set 8255
    out dx, al
    ret
init8255 endp

init8253 proc
    mov dx, CTR_8253
    mov al, 00110110b ; set 8253
    out dx, al
    mov dx, T0_8253
    mov ax, 1000 ; cnt
    out dx, al
    mov al, ah
    out dx, al

    mov dx, CTR_8253
    mov al, 01110110b
    out dx, al
    mov dx, T1_8253
    mov ax, 1000 ; cnt
    out dx, al
    mov al, ah
    out dx, al
    ret
init8253 endp

initM8259 proc
    mov dx, A0_M8259 ; ICW1
    mov al, 00010001b
    out dx, al

    mov dx, A1_M8259 ; ICW2
    mov al, 00001000b ; 16
    out dx, al

    mov al, 10000000b ; ICW3
    out dx, al

    mov al, 01h ; ICW4
    out dx, al

    mov al, 0ffh ; 8259 mask
    out dx, al
    ret
initM8259 endp

initS8259 proc
    mov dx, A0_S8259 ; ICW1
    mov al, 11h
    out dx, al

    mov dx, A1_S8259 ; ICW2
    mov al, 70h ; 从片IR0
    out dx, al

    mov al, 07h ; ICW3
    out dx, al

    mov al, 01h ; ICW4
    out dx, al

    mov al, 0ffh ; 8259 mask
    out dx, al
    ret
initS8259 endp

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

    pop ax
    pop dx
    pop ds
    ret
setIntVector endp

clearIRsMask proc
    push dx
    mov dx, A1_M8259
    in al, dx
    and al, 11111000b ; ocw1
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

    ; call fun
    mov dx, IN0_0809
    call sample0809
    mov fiv, al

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

    ; call fun
    mov dx, IN7_0809
    call sample0809
    mov fivv, al

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

    ; call fun
    call output

    call sendM8259EOI
    cli ; close interrupt
    pop ds
    pop ax
    pop dx
    iret ; return from interrupt
threeHandler endp

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

output proc
    push dx
    push ax

    cmp fiv, ??
    jl outl
    jg outg
    ; 0832  -->> n = (v + 5) * 128 / 5
    ; 153, 179, 204, 230 -->> 1v, 2v, 3v, 4v
    mov al, ??
    jmp final
outl:
    mov al, ??
    jmp final
outg:
    mov al, ??
final:
    call out0832

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

code ends
end start

