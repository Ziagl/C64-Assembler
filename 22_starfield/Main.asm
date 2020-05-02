; The ROL Star Field animation by Richard/TND (From Hyper Duel)
; https://codebase64.org/doku.php?id=base:rol_starfield_using_d018

starcontrol = $0340

; 10 SYS (2064)

*=$0801

        BYTE    $0E, $08, $0A, $00, $9E, $20, $28,  $32, $30, $36, $34, $29, $00, $00, $00

* = $0810
        jsr $ff81
        lda #$00
        sta $d020
        sta $d021
                                       
; Draw starfield to screen $0400
 
        ldx #$00
.copyscreen       
        lda stardata,x
        sta $0400,x
        lda stardata+$100,x
        sta $0500,x
        lda stardata+$200,x
        sta $0600,x
        lda stardata+$2e8,x
        sta $06e8,x
        lda #$0f                ; Light grey stars for now
        sta $d800,x
        sta $d900,x
        sta $da00,x
        sta $dae8,x
        inx
        bne .copyscreen

        lda #<.irq
        sta $0314
        lda #>.irq
        sta $0315
        lda #$7f
        sta $dc0d
        lda #$31
        sta $d012
        lda #$1b
        sta $d011
        lda #$08
        sta $d016
        lda #$1c                ; Char at $3000
        sta $d018
        lda #$01
        sta $d01a               ; Interrupt is on!
        cli
        jmp *                   ; Continuous loop to itself!

.irq    inc $d019               ; $D019 interrupt on
        lda #$fc                ; Raster position 252
        sta $d012
        jsr .starfield
        jmp $ea7e

;Star field source:
;Starfield

.starfield      
        inc starcontrol
        lda starcontrol
        cmp #$03
        beq .doscroll
        rts
.doscroll      
        lda #0
        sta starcontrol
         
        ldx #0
        jsr .starscroll
        jsr .starscroll
        ldx #1
        jsr .starscroll
        ldx #2
        jsr .starscroll
        jsr .starscroll
        jsr .starscroll
        ldx #3
        jsr .starscroll
        ldx #4
        jsr .starscroll
        jsr .starscroll
        jsr .starscroll
        ldx #5
        jsr .starscroll
        jsr .starscroll
        ldx #6
        jsr .starscroll
        ldx #7
        jsr .starscroll
        jsr .starscroll
        rts
         
.starscroll      
        lda $3220,x
        rol $3208,x
        rol $3210,x
        rol $3218,x
        rol $3220,x
        sta $3208,x
        rts

;The starfield char data here. Hell yeah!
;That's what we want :o)

* = $3200
;Shift + * (Blank it)
        byte %00000000
        byte %00100000
        byte %00000000
        byte %00000000
        byte %00000000
        byte %00000010
        byte %00000000
        byte %00000000
;Shift + A
        byte %00000000
        byte %00000000
        byte %00000000
        byte %00000000
        byte %00100000
        byte %00000000
        byte %00000000
        byte %00000000
        byte %01000000
;Shift + B
        byte %00000000
        byte %00000000
        byte %00010000
        byte %00000000
        byte %00000000
        byte %00000000
        byte %00000100
        byte %00000000
;Shift + C
        byte %00000000
        byte %01000000
        byte %00000000
        byte %00000000
        byte %00000000
        byte %00000000
        byte %00001000
        byte %00000000
;Shift + D
        byte %00000010
        byte %00000000
        byte %00000000
        byte %00010000
        byte %00000000
        byte %00000000
        byte %00000000      

;Now for the screen data

*=$4000
stardata
        ptext "BCDABCDABCDABCDABCDABCDABCDABCDABCDABCDA"
        ptext "CDABCDABCDABCDABCDABCDABCDABCDABCDABCDAB"
        ptext "ABCDABCDABCDABCDABCDABCDABCDABCDABCDABCD"
        ptext "DABCDABCDABCDABCDABCDABCDABCDABCDABCDABC"
        ptext "BCDABCDABCDABCDABCDABCDABCDABCDABCDABCDA"
        ptext "CDABCDABCDABCDABCDABCDABCDABCDABCDABCDAB"
        ptext "ABCDABCDABCDABCDABCDABCDABCDABCDABCDABCD"
        ptext "DABCDABCDABCDABCDABCDABCDABCDABCDABCDABC"
        ptext "BCDABCDABCDABCDABCDABCDABCDABCDABCDABCDA"
        ptext "CDABCDABCDABCDABCDABCDABCDABCDABCDABCDAB"
        ptext "ABCDABCDABCDABCDABCDABCDABCDABCDABCDABCD"
        ptext "DABCDABCDABCDABCDABCDABCDABCDABCDABCDABC"
        ptext "BCDABCDABCDABCDABCDABCDABCDABCDABCDABCDA"
        ptext "CDABCDABCDABCDABCDABCDABCDABCDABCDABCDAB"
        ptext "ABCDABCDABCDABCDABCDABCDABCDABCDABCDABCD"
        ptext "DABCDABCDABCDABCDABCDABCDABCDABCDABCDABC"
        ptext "BCDABCDABCDABCDABCDABCDABCDABCDABCDABCDA"
        ptext "CDABCDABCDABCDABCDABCDABCDABCDABCDABCDAB"
        ptext "ABCDABCDABCDABCDABCDABCDABCDABCDABCDABCD"
        ptext "DABCDABCDABCDABCDABCDABCDABCDABCDABCDABC"
        ptext "BCDABCDABCDABCDABCDABCDABCDABCDABCDABCDA"
        ptext "CDABCDABCDABCDABCDABCDABCDABCDABCDABCDAB"
        ptext "ABCDABCDABCDABCDABCDABCDABCDABCDABCDABCD"
        ptext "DABCDABCDABCDABCDABCDABCDABCDABCDABCDABC"
        ptext "BCDABCDABCDABCDABCDABCDABCDABCDABCDABCDA"
        ptext "CDABCDABCDABCDABCDABCDABCDABCDABCDABCDAB"
        ptext "ABCDABCDABCDABCDABCDABCDABCDABCDABCDABCD"
        ptext "DABCDABCDABCDABCDABCDABCDABCDABCDABCDABC"
        byte 0,0,0,0,0,0,0