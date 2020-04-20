*=$0801
        BYTE  $0B, $08, $0A, $00, $9E, $32, $30, $36, $34, $00, $00, $00

*=$0810

; activate register for raster beam and execute code for next cycle

; init interrupt
        sei         ; sets interrupt disable flag
                    ; no interrupts are computed for the moment

        jsr init_screen     ; clear screen to black
        jsr init_text       ; add white text

        ldy #$7f    ; $7f = %01111111
        sty $dc0d   ; Turn off CIAs Timer interrupts
        sty $dd0d   ; Turn off CIAs Timer interrupts
        lda $dc0d   ; cancel all CIA-IRQs in queue/unprocessed
        lda $dd0d   ; cancel all CIA-IRQs in queue/unprocessed

        lda #$01    ; Set Interrupt Request Mask...
        sta $d01a   ; ...we want IRQ by Rasterbeam
                    ; detail see https://sta.c64.org/cbm64mem.html

        ; point to our custom irq routine
        ; we need 2 bytes, because address space is 2 bytes
        lda #<irq
        ldx #>irq 
        sta $314    ; and store in $314/$315 - next irq jumps 
        stx $315    ; to address stored there
        
        lda #$00    ; trigger first interrupt at line zero (can be each line)
        sta $d012

        ; to address all 300 possible raster lines we need 9 bits!
        lda $d011   ; Bit#0 of $d011 is basically...
        and #$7f    ; ...the 9th Bit for $d012
        sta $d011   ; we need to make sure it is set to zero 

        cli         ; clear interrupt disable flag
                    ; interrupts are enabled again

        jmp *       ; infinite loop, wait for interrupt


; interrupt sub-routine is executed once per frame
irq     ; to get also next interrupt we ned ro read and write $d019
        ; instead of lda $d019 and sta $d019 dec is an optimization
        dec $d019        ; acknowledge IRQ

        jsr colwash      ; jump to color cycling routine

        jmp $ea81        ; return to kernel interrupt routine



colwash rts











; code from tutorial 13_statictext
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
