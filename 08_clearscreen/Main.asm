; auto generated sys (Tools->Generate Sys() Call)
; 10 SYS (4096)
*=$0801
        BYTE    $0E, $08, $0A, $00, $9E, $20, $28,  $34, $30, $39, $36, $29, $00, $00, $00

; start address of program in memory 0x1000 = 4096)
*=$1000

SCREEN_START$ = $0400

        SetColor #$00   ; set screen color to black
        ClearScreen     ; clear all characters
LOOP    jmp LOOP        ; loop forever to see result
        

; macro that sets given color to background and border
defm    SetColor
        lda /1
        sta $d020
        sta $d021
        endm

; macro that clears every character on screen 
defm    ClearScreen
        ldx #$00        ; counter init to 0
        lda #$20        ; 0x20 = SPACE character
_LOOP        
        sta SCREEN_START$,x
        sta SCREEN_START$ + $0100,x
        sta SCREEN_START$ + $0200,x
        sta SCREEN_START$ + $0300,x
        dex             ; decrement counter
        bne _LOOP
        endm