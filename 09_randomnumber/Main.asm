; auto generated sys (Tools->Generate Sys() Call)
; 10 SYS (4096)
*=$0801
        BYTE    $0E, $08, $0A, $00, $9E, $20, $28,  $34, $30, $39, $36, $29, $00, $00, $00

; start address of program in memory 0x1000 = 4096)
*=$1000

SCREEN_START$ = $0400
        InitRandom
LOOP1
        PrintRandom SCREEN_START$
        PrintRandom SCREEN_START$ + $0100
        PrintRandom SCREEN_START$ + $0200
        PrintRandom SCREEN_START$ + $0300
        jmp LOOP1

; print random characters to screen (255 chars, 1 byte)
defm    PrintRandom
        ldx #$00
@LOOP   lda $D41B       ; get random value from SID chip
        sta /1,x
        dex
        bne @LOOP
        endm

; initialize SID chip to generate random values
defm    InitRandom
        lda #$FF        ; max frequency value
        sta $D40E       ; voice 3, low byte frequency
        sta $D40F       ; voice 3, high byte frequency
        lda #$80        ; noise waveform, gate bit off
        sta $D412       ; voice 3, controlregister
        endm