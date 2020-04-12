; auto generated sys (Tools->Generate Sys() Call)
; 10 SYS (4096)
*=$0801
        BYTE    $0E, $08, $0A, $00, $9E, $20, $28,  $34, $30, $39, $36, $29, $00, $00, $00

; start address of program in memory 0x1000 = 4096)
*=$1000

SCREEN_START$ = $0400

; this code inverts first 256 characters of display (6 lines of 40 characters and 16 in line 7)
        ldx #$00
LOOP
        lda SCREEN_START$,x
        eor #$80                ; invert color of field
        sta SCREEN_START$,x
        inx
        bne LOOP                ; 256 time till byte overrun and zero flag is 0
        ;rts

; we want to invert whole screen, so we need to do this 4 times -> time for macro
defm    InvertColor
        lda /1,x                ; /1 is first param
        eor #$80
        sta /1,x
        endm

        
        ldx #$00
LOOP1
        ;InvertColor SCREEN_START$              ; first byte already inverted
        InvertColor SCREEN_START$ + $0100
        InvertColor SCREEN_START$ + $0200
        InvertColor SCREEN_START$ + $0300
        inx
        bne LOOP1
        rts