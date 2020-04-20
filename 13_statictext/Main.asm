*=$0801
        BYTE  $0B, $08, $0A, $00, $9E, $32, $30, $36, $34, $00, $00, $00

*=$0810

        jsr init_screen
        jsr init_text

LOOP    jmp LOOP



; the two lines of text for color washer effect

line1   text '    A long time ago, in a galaxy far,    '
line2   text '    far away....                         ' 


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

init_text  
        ldx #$00        ; init X register with $00
loop_text  
        lda line1,x     ; read characters from line1 table of text...
        sta $0590,x     ; ...and store in screen ram near the center
        lda line2,x     ; read characters from line2 table of text...
        sta $05e0,x     ; ...and put 2 rows below line1

        inx 
        cpx #$28        ; finished when all 40 cols of a line are processed
        bne loop_text   ; loop if we are not done yet
        rts
