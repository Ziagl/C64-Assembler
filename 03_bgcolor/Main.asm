; auto generated sys (Tools->Generate Sys() Call)
; 10 SYS (4096)
*=$0801
        BYTE    $0E, $08, $0A, $00, $9E, $20, $28,  $34, $30, $39, $36, $29, $00, $00, $00

; start address of program in memory 0x1000 = 4096)
*=$1000
LOOP
        lda #$02
        sta $d020
        sta $d021
        ;jmp LOOP

        ldx #$20
        lda #$02
        sta $d000,X
        sta $d001,X
        ;jmp LOOP

        ldy #$01
        iny
        sty $d020

        sty $d021
        jmp LOOP