;*********************
;* coded by fiv
;*********************

.model small
.486

port_8259_A_0 equ    xxxx
port_8259_A_1 equ xxxx

port_8253_T0 equ xxxx
port_8253_T1 equ xxxx
port_8253_T2 equ xxxx
port_8253_CTR equ xxxx

port_8255_PA equ xxxx
port_8255_PB equ xxxx
port_8255_PC equ xxxx
port_8255_CTR equ xxxx

port_0809_IN0 equ xxxx
port_0809_IN7 equ xxxx

port_0832 equ xxxx

data segment
    waterLevel db ?
    pollutionDegree db ?
data ends


code segment
assume cs:code,ds:data
start:
    mov ax, data
    mov ds, ax
    call init8255
    call init8253
    call init8259
    call setIntVector
    call clearIRsMask
    sti ; start interrupt
again:
    hlt ; hang up
    jmp again
    hlt

init8255 proc
    mov dx, port_8255_CTR
    mov al, 10000001b ; set 8255
    out dx, al
    ret
init8255 endp

init8253 proc
    mov dx, port_8253_CTR
    mov al, 00110110b ;set 8253
    out dx, al

    mov dx, port_8253_T0
    mov ax, 1000 ; cnt
    out dx, al
    mov al, ah
    out dx, al
    ret
init8253 endp

init8259 proc
    push dx
    mov dx, port_8259_A_0
    mov al, 00010011b ;icw1
    out dx, al
    mov dx, port_8259_A_1
    mov al, 00111000b ;icw2
    out dx, al
    mov dx, port_8259_A_1
    mov al, 00000001b ;icw4
    out dx, al
    pop dx
    ret
init8259 endp

setIntVector proc
    push dx
    push ds

    xor ax, ax
    mov ds, ax

    mov ax, seg timer0handler
    mov si, 224 ; 4 * 56
    mov word ptr[si + 2], ax
    mov ax, offset timer0handler
    mov word ptr[si], ax

    mov ax, seg timer1handler
    mov word ptr[4 * 57 + 2], ax
    mov ax, offset timer1handler
    mov word ptr[4 * 57], ax

    mov ax, seg timer2handler
    mov word ptr[4 * 58 + 2], ax
    mov ax, offset timer2handler
    mov word ptr[4 * 58], ax

    pop ds
    pop dx
    ret
setIntVector endp

timer0handler proc
    push dx
    push ax
    push ds

    sti ; start interrupt
    mov ax, data
    mov ds, ax

    mov dx, port_0832 ; 根据水质污染程度生成控制量al
    out dx, al

    mov dx, port_8255_PC ; 根据水位生成控制量al
    out dx, al

    call send8259EOI
    cli ; close interrupt

    pop ds
    pop ax
    pop dx
    iret ; interrupt return
timer0handler endp

timer1handler proc
    push dx
    push ax
    push ds

    sti
    mov ax, data
    mov ds, ax

    mov dx, port_0809_IN0
    call sample0809
    mov waterLevel, al

    call send8259EOI
    cli

    pop ds
    pop ax
    pop dx
    iret
timer1handler endp

timer2handler proc
    push dx
    push ax
    push ds

    sti
    mov ax, data
    mov ds, ax

    mov dx, port_0809_IN7
    call sample0809
    mov pollutionDegree, al

    call send8259EOI
    cli

    pop ds
    pop ax
    pop dx
    iret
timer2handler endp

sample0809 proc
    push dx
    ;; mov al, 3    -->> channel
    out dx, al ; start sample 0809

    push dx
    mov dx, port_8255_PC
next:
    in dx, al
    test al, 01h  ; PC0
    jz next
    pop dx
    in al, dx ; read data from 0809
    pop dx
    ret
sample0809 endp

send8259EOI proc
    push dx
    mov dx, port_8259_A_0
    mov al, 00100000b ; ocw2 = 0010 0000
    out dx, al  ;send interrupt to 8259
    pop dx
send8259EOI endp

clearIRsMask proc
    push dx
    mov dx, port_8259_A_1
    in al, dx
    and al, 11111000b ; ocw1
    out dx, al ; clear mask of IR3
    pop dx
    ret
code ends
end start

