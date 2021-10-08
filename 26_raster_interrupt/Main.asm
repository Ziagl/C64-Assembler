; auto generated sys (Tools->Generate Sys() Call)
; 10 SYS (4096)
*=$0801
        BYTE    $0E, $08, $0A, $00, $9E, $20, $28,  $34, $30, $39, $36, $29, $00, $00, $00

; start address of program in memory 0x1000 = 4096)
*=$1000

BORDERCOLOR = $0345     ; storage for border color
COUNTER = $0346         ; storage for color loop counter

Init    ldy #$1         ; initialize BORDERCOLOR value to white
        sty BORDERCOLOR

        lda #$0         ; set content background color to black
        sta $d021

        lda #$1         ; set text color to white
        sta $0286

        sei             ; set interrupt bit, make the CPU ignore interrupt requests
        lda #%01111111  ; switch off interrupt signals from CIA-1
        sta $dc0d

        and $d011       ; clear most significant bit of VIC's raster register
        sta $d011

        lda $dc0d       ; acknowledge pending interrupts from CIA-1
        lda $dd0d       ; acknowledge pending interrupts from CIA-2

        lda #$35        ; set rasterline where interrupt shall occur
        sta $d012

        lda #<Irq       ; set interrupt vectors, pointing to interrupt service routine below
        sta $0314
        lda #>Irq
        sta $0315

        lda #%00000001  ; enable raster interrupt signals from VIC
        sta $d01a

        cli             ; clear interrupt flag, allowing the CPU to respond to interrupt requests
        rts

; this is the interrupt routine
; it is fired after scanline interrupt is detected
Irq     lda #16         ; initialize color loop counter to 16 (max number of colors)
        sta COUNTER

Loop    lda BORDERCOLOR
        sta $d020       ; change border colour to BORDERCOLOR

        ldx #$90        ; empty loop to do nothing for just under half a millisecond
Pause   dex
        bne Pause

        inc BORDERCOLOR ; increment BORDERCOLOR value

        dec COUNTER     ; decrement color loop counter
        bne Loop        ; loop this for every color

        lda #$0
        sta $d020       ; change border colour to black

        asl $d019       ; acknowledge the interrupt by clearing the VIC's interrupt flag

        jmp $ea31       ; jump into KERNAL's standard interrupt service routine to handle keyboard scan, cursor display etc.
