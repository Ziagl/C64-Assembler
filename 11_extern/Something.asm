       
*=$9000

; local macro
defm    DoIt
        ldy #$00
@LOOP
        bne @LOOP
        endm

; subroutine
DOSOMETHING
        DoIt    ; calls macro
        rts