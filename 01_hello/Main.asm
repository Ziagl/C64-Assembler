; auto generated sys (Tools->Generate Sys() Call)
; 10 SYS (4096)
*=$0801
        BYTE    $0E, $08, $0A, $00, $9E, $20, $28,  $34, $30, $39, $36, $29, $00, $00, $00

; start address of program in memory 0x1000 = 4096)
*=$1000

; local variables
BASIC_PRINT_FILE = $AB1E

; label START
START
        lda #<HELLOWORLD
        ldy #>HELLOWORLD
        jsr BASIC_PRINT_FILE
        jmp START

HELLOWORLD
        ptext "HELLO WORLD"
        byte 13, 00