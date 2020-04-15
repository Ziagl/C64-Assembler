*=$0801

        BYTE  $0B, $08, $0A, $00, $9E, $32, $30, $36, $34, $00, $00, $00

; *.koa file format
;1) 2 byte header
;2) 8000 bytes pixel data
;3) 1000 byte character data (that I ignore)
;4) 1000 byte color data
;5) 1 byte background color

*=$0810
        lda $DD00
        and #%11111100
        ora #%00000010 ; Change Bank to 1
        sta $DD00

        lda $8710
        sta $d021
        lda #0
        sta $d020
    

        lda $d011
        ora #32
        sta $d011
        lda $d016
        ora #$10
        sta $d016
                ;$d011=$3b, $d016=$18
        lda $d011
        ora #32
        sta $d011
       
        lda $d016
        ora #16
        sta $d016


        lda #08        ;screenram at $4000 , bitmap at+$2000
        sta $d018
        
        ldx #0

        lda #$00

cppy                    ; copy screenram and colormem
        lda $7f40,x
        sta $4000,x
        lda $8328,x
        sta $d800,x

        lda $8040,x
        sta $4100,x
        lda $8428,x
        sta $d900,x

        lda $8140,x
        sta $4200,x
        lda $8528,x
        sta $da00,x

        lda $8240,x
        sta $4300,x
        lda $8628,x
        sta $db00,x
        inx
        bne cppy

LOOP    jmp LOOP

*=$5FFE ; -2 for loadadress
        INCBIN "mclaren.koa"