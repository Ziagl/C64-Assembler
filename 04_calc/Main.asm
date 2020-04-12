; auto generated sys (Tools->Generate Sys() Call)
; 10 SYS (4096)
*=$0801
        BYTE    $0E, $08, $0A, $00, $9E, $20, $28,  $34, $30, $39, $36, $29, $00, $00, $00

; start address of program in memory 0x1000 = 4096)
*=$1000
LOOP
        lda #$00
        sta $d020
        clc
        adc #$01
        sta $d021
        ;jmp LOOP

        lda #$01
        sta $d021
        sec
        sbc #$01
        sta $d020
        jmp LOOP