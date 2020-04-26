*=$0801
        BYTE  $0B, $08, $0A, $00, $9E, $32, $30, $36, $34, $00, $00, $00
*=$0810

        jsr init_screen
        jsr init_sprites

LOOP    jmp LOOP


; initialize screen to black
init_screen      
        ldx #$00      ; set X to zero (black color code)
        stx $d021     ; set background color
        stx $d020     ; set border color

clear   lda #$20      ; #$20 is the spacebar Screen Code
        sta $0400,x   ; fill four areas with 256 spacebar characters
        sta $0500,x 
        sta $0600,x 
        sta $06e8,x 
        lda #$01      ; set foreground to white in Color Ram 
        sta $d800,x  
        sta $d900,x
        sta $da00,x
        sta $dae8,x
        inx           ; increment X
        bne clear     ; did X turn to zero yet?
                      ; if not, continue with the loop
        rts           ; return from this subroutine

init_sprites
        ; pointer to sprite 1
        lda #$80
        sta $07f8
        ; pointer to sprite 2
        lda #$89
        sta $07f9
        ; enable sprite 1 and 2
        lda #$03
        sta $d015
        ; set Multicolor mode for Sprite 1 and 2
        lda #$03
        sta $d01c
        ; Sprite 1 has priority over background
        lda #$01
        sta $d01b

        lda #00         ; Sprite 1 background color
        sta $d021
        lda #09         ; Sprite 1 multicolor 1
        sta $d025
        lda #08         ; Sprite 1 multicolor 2
        sta $d026
        lda #04         ; Sprite 1 main color
        sta $d027
        lda #06         ; Sprite 2 main color
        sta $d028

        ; set x,y position 80 = 128/128
        lda #$80
        sta $d000
        sta $d001

        lda #$A0
        sta $d002
        lda #$80
        sta $d003

        rts

*=$2000
        INCBIN "emi.spt",1,9,true
        INCBIN "liam.spt",1,9,true