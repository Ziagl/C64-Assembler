; auto generated sys (Tools->Generate Sys() Call)
; 10 SYS (4096)
*=$0801
        BYTE    $0E, $08, $0A, $00, $9E, $20, $28,  $34, $30, $39, $36, $29, $00, $00, $00

; start address of program in memory 0x1000 = 4096)
*=$1000
        ; set border color to image color
        lda $4710
        sta $d020
        sta $d021

        ; copy image data to screen memory
        ldx #$00
IMAGE   lda $3F40,x
        sta $0400,x
        lda $4040,x
        sta $0500,x
        lda $4140,x
        sta $0600,x
        lda $4240,x
        sta $0700,x
        
        lda $4328,x
        sta $D800,x
        lda $4428,x
        sta $D900,x
        lda $4528,x
        sta $DA00,x
        lda $4628,x
        sta $DB00,x
        inx
        bne IMAGE
        
        ; switch screen mode to bitmap mode
        lda #$3B
        sta $D011
        ; turn on multicolor-mode
        lda #$18
        sta $D016

        ; info for VIC
        lda #$18
        sta $D018

LOOP    jmp LOOP
        

*=$1FFE
        INCBIN "mclaren.prg"