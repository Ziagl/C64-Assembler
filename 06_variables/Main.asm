; auto generated sys (Tools->Generate Sys() Call)
; 10 SYS (4096)
*=$0801
        BYTE    $0E, $08, $0A, $00, $9E, $20, $28,  $34, $30, $39, $36, $29, $00, $00, $00

; start address of program in memory 0x1000 = 4096)
*=$1000
       
; variables
VAR_BIN = %10010111     ; local variable binary representation
VAR_HEX = $97           ; local variable hexadecimal representation
VAR_OCT = @227          ; local variable octal representation
VAR_DEC = 151           ; local variable decimal represenetation

VAR_GLOBAL$ = $2000     ; global variable hexadecimal representation

SCREEN_START$ = $0400   ; global screen start position (first character)

        ldx #$00
LOOP                    ; label always starts at column 0 of file!
        txa
        sta SCREEN_START$,x
        inx
        bne LOOP
_TEMP                   ; temporary label, only visible in block between labels
        lda #$00
        sta $d021
        rts