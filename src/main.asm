[org 0x7c00]
[bits 16]

_start:
    call SetupDisplay
    push 0x013f ; X End
    push 0x00c7 ; Y End

    push 0x0000 ; X Start Point 1
    push 0x0000 ; Y Start 
    call Bresenhams
    add sp, 0x8

    push 0x013f ; Point 2
    push 0x0000

    push 0x0000 ; Point1
    push 0x00c7
    call Bresenhams

    jmp $

%include "src/graphics.asm"

times 510-($-$$) db 0
dw 0xAA55