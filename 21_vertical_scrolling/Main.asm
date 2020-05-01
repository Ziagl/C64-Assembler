*=$0801
        BYTE  $0B, $08, $0A, $00, $9E, $32, $30, $36, $34, $00, $00, $00

*=$0810

FIXEDLINES  = 0                    ; lines that stay still (0 = move whole screen)
STARTLINE   = 48+FIXEDLINES*8      ; start position (FIXESLINES * 8 for char height)
SKIPLINES   = 255                  ; empty space between STARTLINE and screen

        lda #$00                   ; color for empty space
        sta $3fff                  ; set color for empty space     
 
        sei                        ; deactivate interrupts
 
@loop 
        lda #SKIPLINES             ; store new number of lines to skip
        sta linesToSkip
 
@loop1
        jsr waitForNewFrame        ; wait for next redraw
 
        lda #%00011011             ; init $d011 with default value
        sta $d011
 
        lda #STARTLINE             ; wait till raster reaches STARTLINE
        cmp $d012
        bne *-3
 
        ldx linesToSkip            ; store linesToSkip to X register
        beq @loop                  ; restart if 0 (animation  complete)
 
@loop2 
        lda $d012                  ; wait for next line
        cmp $d012
        beq *-3
 
        clc                        ; increment Y position (bit 0 - 2 = 8 lines)
        lda $d011
        adc #1
        and #%00000111
        ora #%00011000
        sta $d011                  ; store it back to $d011
 
        dex
        bne @loop2                 ; as long as not 0
 
        dec linesToSkip            ; reduce linesToSkip
 
        jmp @loop1                 ; next frame
 
waitForNewFrame
        lda $d011                      
        bpl *-3                     ; wait while $d011 is positive
        lda $d011                      
        bmi *-3                     ; wait while $d011 is negative
        rts                         ; msbit was removed 
 
linesToSkip
        byte SKIPLINES