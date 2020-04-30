*=$0801
        BYTE  $0B, $08, $0A, $00, $9E, $32, $30, $36, $34, $00, $00, $00
*=$0810

; global (sprite1 and sprite2)
animation_walk_start = #$00
animation_walk_end = #$03
sprite_max = #$09

; sprite 1
sprite1_y = #$70
sprite1_x = #$15
sprite1_x1 = #$00
sprite1_start = #$80


; sprite 2
sprite2_y = #$80
sprite2_x = #$2F
sprite2_x1 = #$02
sprite2_start = #$89

; sprite 3
sprite3_y = #$a0
sprite3_x = #$2F
sprite3_x1 = #$04
sprite3_start = #$92

sprite_source = $40
sprite_destination = $42

main
        sei           ; set interrupt disable flag
        jsr init_screen
        jsr init_sprites

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
        jmp *


; interrupt
irq     dec $d019
        jsr animate_sprites
        jmp $ea81


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

; initialize sprites
init_sprites
        ; pointer to sprite 1
        lda sprite1_start
        sta $07f8
        ; pointer to sprite 2
        lda sprite2_start
        sta $07f9
        ; pointer to sprite 3
        lda sprite3_start
        sta $07fa
        ; enable sprite 1 and 2 and 3
        lda #%00000111
        sta $d015
        ; set Multicolor mode for Sprite 1 and 2 and 8
        lda #%00000111
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
        lda #05         ; Sprite 3 main color
        sta $d029

        jsr set_sprites_position

        ; flip sprite horizontally
        ; source is sprite 2 which starts at $2240 ($2000 + 9 * 64 bytes)
        lda #$40
        sta sprite_source
        lda #$22
        sta sprite_source+1
        ; destination is sprite 3 which starts at 2480 (2240 + 9 * 64 bytes)
        lda #$80
        sta sprite_destination
        lda #$24
        sta sprite_destination+1
        jsr GenerateBitFlipLookupTable
        ; flip every sprite in sprite animation (9 single sprites)
        ldx #$09        ; counter
@loop
        txa
        ; store accumulator to stack
        pha
        jsr FlipSpriteHorizontally
        
        ; move to next sprite source
        lda sprite_source
        clc
        adc #$40                ; 64 bytes (size of one single sprite)
        bcc @skip_src
        inc sprite_source+1
@skip_src
        sta sprite_source
        ;move to next sprite destination
        lda sprite_destination
        clc
        adc #$40                ; 64 bytes
        bcc @skip_dest
        inc sprite_destination+1
@skip_dest
        sta sprite_destination

        ; restore accumulator from stack
        pla
        tax
        dex
        bne @loop
        rts

; sets x and y position of both sprites
set_sprites_position
        ; set x,y position 80 = 128/128
        lda sprite1_x
        sta $d000
        lda sprite1_y
        sta $d001

        lda sprite2_x
        sta $d002
        lda sprite2_y
        sta $d003

        lda sprite3_x
        sta $d004
        lda sprite3_y
        sta $d005

        lda sprite2_x1  ; set X-Coord high bit (9th Bit)
        adc sprite3_x1
        sta $d010
        rts

animate_sprites
        ; set pointer to sprite on next animation position
        lda sprite1_start
        ldx sprite_frame
        adc walk_animation,x
        sta $07f8
        lda sprite2_start
        adc walk_animation,x
        sta $07f9
        lda sprite3_start
        adc walk_animation,x
        sta $07fa

        ; increment frame
        inc sprite_frame

        ; if  max <= frame: increment pointer
        lda animation_walk_end
        cmp sprite_frame
        bcs @set_animation_frame
        ; else: set pointer to first frame
        lda animation_walk_start
        sta sprite_frame
        
@set_animation_frame
        rts

FlipSpriteHorizontally
        ldy #$0                        ; src index
@Loop
        lda (sprite_source),Y          ; load original byte                     
        tax                            ; use original byte as index into bitflip table
        lda sprite_flip_lookup_table,X ; A now containes flipped bits
        ; first read byte goes to third output byte
        iny                            
        iny
        sta (sprite_destination),y     ; store at destination+Y bytes
        dey                            ; go back 1 byte... net result = 1 forward
        ; second original byte
        lda (sprite_source),Y           
        tax
        lda sprite_flip_lookup_table,X
        sta (sprite_destination),y     ; second read byte goes to second output
        iny
        ; third input byte
        lda (sprite_source),Y           
        tax
        lda sprite_flip_lookup_table,X
        dey
        dey
        sta (sprite_destination),y     ; third input byte goes to first output
        iny                            ; move to next line
        iny
        iny
        cpy #63
        bne @Loop
        rts


; source: https://github.com/svenvermeulen/C64SVGfxFunctions/blob/master/spriteroutines.asm
; Generates a lookup table for bit flipping (for use by horizontal single-sprite flipper)
; only works for single color mode
;========================================================================================
;GenerateBitFlipLookupTable
;        LDX #$1         ; Original Value = Offset into table
;                        ; byte 0 needs not be calculated so I start at 1
;                        ; Y will be used for tmp storage
;        LDA #$0         ; A will be used for calculating result
;        STA sprite_flip_lookup_table
;SVGFX_Loop_GenBFLT
;        LDY #$0         ; count bitshift iterations for current input value
;        TXA             ; A will be calculated based on current offset (x)
;SVGFX_GBF_Bit0
;        TXA             ; A will be calculated based on current offset (x)
;        AND #%00000001
;        BEQ SVGFX_GBF_Bit1
;        TYA
;        ORA #%10000000
;        TAY
;SVGFX_GBF_Bit1
;        TXA
;        AND #%00000010
;        BEQ SVGFX_GBF_Bit2
;        TYA
;        ORA #%01000000
;        TAY
;SVGFX_GBF_Bit2
;        TXA
;        AND #%00000100
;        BEQ SVGFX_GBF_Bit3
;        TYA
;        ORA #%00100000
;        TAY
;SVGFX_GBF_Bit3
;        TXA
;        AND #%00001000
;        BEQ SVGFX_GBF_Bit4
;        TYA
;        ORA #%00010000
;        TAY
;SVGFX_GBF_Bit4
;        TXA
;        AND #%00010000
;        BEQ SVGFX_GBF_Bit5
;        TYA
;        ORA #%00001000
;        TAY
;SVGFX_GBF_Bit5
;        TXA
;        AND #%00100000
;        BEQ SVGFX_GBF_Bit6
;        TYA
;        ORA #%00000100
;        TAY
;SVGFX_GBF_Bit6
;        TXA
;        AND #%01000000
;        BEQ SVGFX_GBF_Bit7
;        TYA
;        ORA #%00000010
;        TAY
;SVGFX_GBF_Bit7
;        TXA
;        AND #%10000000
;        BEQ SVGFX_GBF_NextByte
;        TYA
;        ORA #%00000001
;        TAY
;SVGFX_GBF_NextByte
;        TYA             ; cannot remove this because previous TAY is not ALWAYS executed
;        STA sprite_flip_lookup_table,x
;        INX             ; next byte please
;        CPX #$FF
;        BNE SVGFX_Loop_GenBFLT
;        TXA
;        STA sprite_flip_lookup_table,x
;
;        RTS             ; all done
;========================================================================================

; code for multi-color code
GenerateBitFlipLookupTable
        ldx #$1         ; Original Value = Offset into table
                        ; byte 0 needs not be calculated so I start at 1
                        ; Y will be used for tmp storage
        lda #$0         ; A will be used for calculating result
        sta sprite_flip_lookup_table
@Loop
        ldy #$0         ; count bitshift iterations for current input value
        txa             ; A will be calculated based on current offset (x)
@Bit0
        txa             ; A will be calculated based on current offset (x)
        and #%00000001
        beq @Bit1
        tya
        ora #%01000000
        tay
@Bit1
        txa
        and #%00000010
        beq @Bit2
        tya
        ora #%10000000
        tay
@Bit2
        txa
        and #%00000100
        beq @Bit3
        tya
        ora #%00010000
        tay
@Bit3
        txa
        and #%00001000
        beq @Bit4
        tya
        ora #%00100000
        tay
@Bit4
        txa
        and #%00010000
        beq @Bit5
        tya
        ora #%00000100
        tay
@Bit5
        txa
        and #%00100000
        beq @Bit6
        tya
        ora #%00001000
        tay
@Bit6
        txa
        and #%01000000
        beq @Bit7
        tya
        ora #%00000001
        tay
@Bit7
        txa
        and #%10000000
        beq @NextByte
        tya
        ora #%00000010
        tay
@NextByte
        tya             ; cannot remove this because previous TAY is not ALWAYS executed
        sta sprite_flip_lookup_table,x
        inx             ; next byte please
        cpx #$FF
        bne @Loop
        txa
        sta sprite_flip_lookup_table,x
        rts

*=$2000
        INCBIN "emi.spt",1,9,true
        INCBIN "liam.spt",1,9,true
        INCBIN "liam.spt",1,9,true

sprite_frame byte 0
walk_animation  byte $02,$03,$04,$03

; Lookup table maps byte value to
; bits flipped value
; input value = index to table
; example %11000000 -> %00000011
sprite_flip_lookup_table
        bytes   $ff