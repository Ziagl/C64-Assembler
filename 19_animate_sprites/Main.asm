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
sprite2_start = #$80 + sprite_max

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

        jsr set_sprites_position
        
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

        lda sprite2_x1  ; set X-Coord high bit (9th Bit)
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


*=$2000
        INCBIN "emi.spt",1,9,true
        INCBIN "liam.spt",1,9,true

sprite_frame byte 0
walk_animation  byte $02,$03,$04,$03