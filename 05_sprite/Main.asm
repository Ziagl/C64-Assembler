; auto generated sys (Tools->Generate Sys() Call)
; 10 SYS (4096)
*=$0801
        BYTE    $0E, $08, $0A, $00, $9E, $20, $28,  $34, $30, $39, $36, $29, $00, $00, $00

; start address of program in memory 0x1000 = 4096)
*=$1000
        ; pointer to sprite
        lda #$80
        sta $07f8

        ; enable sprite 1
        lda #$01
        sta $d015

        ; set x,y position 80 = 128/128
        lda #$80
        sta $d000
        sta $d001

LOOP    jmp LOOP

*=$2000
        INCBIN "sprite.spt",1,1
        