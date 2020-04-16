
*=$0801
        BYTE  $0B, $08, $0A, $00, $9E, $32, $30, $36, $34, $00, $00, $00

*=$0810
start
        ldx #$00
        jsr DOSOMETHING         ; call external subroutine
        inx

        INCASM "Something.asm"  ; include extern asm file