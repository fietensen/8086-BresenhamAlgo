SetupDisplay:
    pusha

    mov ax, 0x0004
    int 0x10

    popa
    ret

DrawPoint:
    ; cx = X
    ; dx = Y
    pusha
    mov ax, 0x0c0f
    mov bh, 0x00
    int 0x10
    popa
    ret

fABS:
    ; ax = X
    cwd
    xor ax, dx
    sub ax, dx
    ret

Bresenhams: 
    ; 2 points on stack; point = 4 bytes X,Y
    mov bp, sp
    pusha

    push word [bp+8]; dX = X end
    push word [bp+6]; dY = Y end
    push 0x0000 ; sX
    push 0x0000 ; sY
    push 0x0000 ; error
    push 0x0000 ; e2

    mov si, sp ; si = dX
    mov di, si ; di = dY
    add si, 0xa
    add di, 0x8
    
    mov bx, word [bp+4] ; bx = X Start
    sub [si], bx        ; dx = X End - X Start
    mov bx, word [bp+2] ; bx = Y Start
    sub [di], bx        ; dy = Y End - Y Start

    mov ax, [si]
    call fABS
    mov [si], ax
    mov ax, [di]
    call fABS
    neg ax
    mov [di], ax

    ; set error
    ; error = sp+4
    mov bx, sp
    mov ax, [si]
    add [bx+0x2], ax
    mov ax, [di]
    add [bx+0x2], ax

    lea bx, [di-2] ; sx
    mov ax, [bp+4] ; x start
    cmp ax, [bp+8]
    jge _x0ge
    mov word [bx], 0x01
    jmp _fns_sx
_x0ge:
    mov word [bx], -0x01
_fns_sx:

    lea bx, [di-4] ; sy
    mov ax, [bp+2] ; y start
    cmp ax, [bp+6]
    jge _y0ge
    mov word [bx], 0x01
    jmp _fns_sy
_y0ge:
    mov word [bx], -0x01
_fns_sy:
    lea si, [bp+4]; make x0 indexable
    lea di, [bp+2]; make y0 indexable

_loop:
    mov cx, [si]
    mov dx, [di]
    call DrawPoint
    mov ax, [si]
    cmp ax, [bp+8]
    jne _end_cmp_loopexit
    mov ax, [di]
    cmp ax, [bp+6]
    jne _end_cmp_loopexit
    jmp _end
_end_cmp_loopexit:
    mov bx, sp
    ; ax = 2*error
    
    mov ax, [bx+0x2]
    mov word [bx], 0x0002
    mul word [bx]

    cmp ax, [bx+0x8] ; comparing e2 and dY
    jle _e2_ledy

    ; add dY to error
    push ax
    mov ax, [bx+0x8] ; load dY into ax
    add [bx+0x2], ax ; add ax to error
    ; add sx to x0

    mov ax, [bx+0x6]
    add [si], ax

    pop ax
_e2_ledy:
    cmp ax, [bx+0xa] ; comparing e2 and dx
    jge _e2_gedx
    ;jmp _end
    ; add dx to error
    push ax
    mov ax, [bx+0xa]
    add [bx+0x2], ax
    ; add sy to y0

    mov ax, [bx+0x4]
    add [di], ax

    pop ax
_e2_gedx:
    jmp _loop
_end:
    add sp, 0xc
    popa
    ret