; original source: 
; https://codebase64.org/doku.php?id=magazines:chacking6#the_demo_cornerdycp_-_horizontal_scrolling

SINUS=   $CF00   ; Place for the sinus table
CHRSET=  $3800   ; Here begins the character set memory
GFX=     $3C00   ; Here we plot the dycp data
X16=     $CE00   ; values multiplicated by 16 (0,16,32..)
D16=     $CE30   ; divided by 16  (16 x 0,16 x 1 ...)
START=   $033C   ; Pointer to the start of the sinus
COUNTER= $033D   ; Scroll counter (x-scroll register)
POINTER= $033E   ; Pointer to the text char
YPOS=    $0340   ; Lower 4 bits of the character y positions
YPOSH=   $0368   ; y positions divided by 16
CHAR=    $0390   ; Scroll text characters, multiplicated by eight
ZP=      $FB     ; Zeropage area for indirect addressing
ZP2=     $FD
AMOUNT=  38      ; Amount of chars to plot-1
PADCHAR= 32      ; Code used for clearing the screen

*=$0801
        BYTE  $0B, $08, $0A, $00, $9E, $32, $30, $36, $34, $00, $00, $00
*=$0810

        sei             ; Disable interrupts

        ldx #$00        ; set X to zero (black color code)
        stx $d021       ; set background color
        stx $d020       ; set border color
   
        lda #$01      ; set foreground to white in Color Ram 
clear
        sta $d800,x  
        sta $d900,x
        sta $da00,x
        sta $dae8,x
        inx           ; increment X
        bne clear

        lda #$32        ; Character generator ROM to address space
        sta $01
        ldx #0
LOOP0   lda $D000,X     ; Copy the character set
        sta CHRSET,X
        lda $D100,X
        sta CHRSET+256,X
        dex
        bne LOOP0
        lda #$37        ; Normal memory configuration
        sta $01
        ldy #31
LOOP1   lda #66         ; Compose a full sinus from a 1/4th of a
        clc             ;   cycle
        adc SIN,X
        sta SINUS,X
        sta SINUS+32,Y
        lda #64
        sec
        sbc SIN,X
        sta SINUS+64,X
        sta SINUS+96,Y
        inx
        dey
        bpl LOOP1
        ldx #$7F
LOOP2   lda SINUS,X
        lsr
        clc
        adc #32
        sta SINUS+128,X
        dex
        bpl LOOP2

        ldx #39
LOOP3   txa
        asl
        asl
        asl
        asl
        sta X16,X       ; Multiplication table (for speed)
        txa
        lsr
        lsr
        lsr
        lsr
        clc
        adc #>GFX
        sta D16,X       ; Dividing table
        lda #0
        sta CHAR,X      ; Clear the scroll
        dex
        bpl LOOP3
        sta POINTER     ; Initialize the scroll pointer
        ldx #7
        stx COUNTER
LOOP10  sta CHRSET,X    ; Clear the @-sign..
        dex
        bpl LOOP10

        LDA #>CHRSET    ; The right page for addressing
        STA ZP2+1
        LDA #<IRQ       ; Our interrupt handler address
        STA $0314
        LDA #>IRQ
        STA $0315
        LDA #$7F        ; Disable timer interrupts
        STA $DC0D
        LDA #$81        ; Enable raster interrupts
        STA $D01A
        LDA #$A8        ; Raster compare to scan line $A8
        STA $D012
        LDA #$1B        ; 9th bit
        STA $D011
        LDA #30
        STA $D018       ; Use the new charset
        CLI             ; Enable interrupts and return
        RTS

IRQ     INC START       ; Increase counter
        LDY #AMOUNT
        LDX START
LOOP4   LDA SINUS,X     ; Count a pointer for each text char and according
        AND #7          ;  to it fetch a y-position from the sinus table
        STA YPOS,Y      ;   Then divide it to two bytes
        LDA SINUS,X
        LSR
        LSR
        LSR
        STA YPOSH,Y
        INX             ; Chars are two positions apart
        INX
        DEY
        BPL LOOP4

        LDA #0
        LDX #79
LOOP11  STA GFX,X       ; Clear the dycp data
        STA GFX+80,X
        STA GFX+160,X
        STA GFX+240,X
        STA GFX+320,X
        STA GFX+400,X
        STA GFX+480,X
        STA GFX+560,X
        DEX
        BPL LOOP11

MAKE    LDA COUNTER     ; Set x-scroll register
        STA $D016
        LDX #AMOUNT
        CLC             ; Clear carry
LOOP5   LDY YPOSH,X     ; Determine the position in video matrix
        TXA
        ADC LINESL,Y    ; Carry won't be set here
        STA ZP          ; low byte
        LDA #4
        ADC LINESH,Y
        STA ZP+1        ; high byte
        LDA #PADCHAR    ; First clear above and below the char
        LDY #0          ; 0. row
        STA (ZP),Y
        LDY #120        ; 3. row
        STA (ZP),Y
        TXA             ; Then put consecuent character codes to the places
        ASL             ;  Carry will be cleared
        ORA #$80        ; Inverted chars
        LDY #40         ; 1. row
        STA (ZP),Y
        ADC #1          ; Increase the character code, Carry won't be set
        LDY #80         ; 2. row
        STA (ZP),Y

        LDA CHAR,X      ; What character to plot ? (source)
        STA ZP2         ;  (char is already multiplicated by eight)
        LDA X16,X       ; Destination low byte
        ADC YPOS,X      ;  (16*char code + y-position's 3 lowest bits)
        STA ZP
        LDA D16,X       ; Destination high byte
        STA ZP+1

        LDY #6          ; Transfer 7 bytes from source to destination
        LDA (ZP2),Y
        STA (ZP),Y
        DEY             ; This is the fastest way I could think of.
        LDA (ZP2),Y
        STA (ZP),Y
        DEY
        LDA (ZP2),Y
        STA (ZP),Y
        DEY
        LDA (ZP2),Y
        STA (ZP),Y
        DEY
        LDA (ZP2),Y
        STA (ZP),Y
        dey
        lda (ZP2),Y
        sta (ZP),Y
        dey
        lda (ZP2),Y
        sta (ZP),Y
        dex
        bpl LOOP5       ; Get next char in scroll

        lda #1
        sta $D019       ; Acknowledge raster interrupt

        dec COUNTER     ; Decrease the counter = move the scroll by 1 pixel
        bpl OUT
LOOP12  lda CHAR+1,Y    ; Move the text one position to the left
        sta CHAR,Y      ;  (Y-register is initially zero)
        iny
        cpy #AMOUNT
        bne LOOP12
        lda POINTER
        and #63         ; Text is 64 bytes long
        tax
        lda SCROLL,X    ; Load a new char and multiply it by eight
        asl
        asl
        asl
        sta CHAR+AMOUNT ; Save it to the right side
        dec START       ; Compensation for the text scrolling
        dec START
        inc POINTER     ; Increase the text pointer
        lda #7
        sta COUNTER     ; Initialize X-scroll

OUT     jmp $EA7E       ; Return from interrupt

SIN     byte 0,3,6,9,12,15,18,21,24,27,30,32,35,38,40,42,45
        byte 47,49,51,53,54,56,57,59,60,61,62,62,63,63,63
        ; 1/4 of the sinus

LINESL  byte 0,40,80,120,160,200,240,24,64,104,144,184,224
        byte 8,48,88,128,168,208,248,32

LINESH  byte 0,0,0,0,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,2,3

SCROLL  ptext "THIS@IS@AN@EXAMPLE@SCROLL@FOR@"
        ptext "COMMODORE@MAGAZINE@BY@PASI@OJALA@@"
        ; SCR will convert text to screen codes