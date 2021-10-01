; auto generated sys (Tools->Generate Sys() Call)
; 10 SYS (4096)
*=$0801
        BYTE    $0E, $08, $0A, $00, $9E, $20, $28,  $34, $30, $39, $36, $29, $00, $00, $00

; start address of program in memory 0x1000 = 4096)
*=$1000

BSOUT = $ffd2
        
START
        ldx #22         ; line
        ldy #10         ; colum
        clc
        jsr $fff0

        ldx #$00
LOOP
        lda HELLOWORLD,X
        beq END
        jsr BSOUT
        inx
        jmp LOOP

END
        rts

HELLOWORLD
        ptext "HELLO WORLD"
        byte 00