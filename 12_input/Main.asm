*=$0801
        BYTE  $0B, $08, $0A, $00, $9E, $32, $30, $36, $34, $00, $00, $00

*=$0810

; know-how from https://dustlayer.com/c64-coding-tutorials/2013/5/24/episode-3-5-taking-command-of-the-ship-controls
; CIA 6526 chip
pra  =  $dc00            ; port register A
prb  =  $dc01            ; port register B
ddra =  $dc02            ; data direction register A
ddrb =  $dc03            ; data direction register B

        ; initialize CIA
        lda #%11111111  ; port A needs to be set to output 
        sta ddra             
        lda #%00000000  ; port B needs to be set to input
        sta ddrb  

        ; pointer to sprite
        lda #$80
        sta $07f8

        ; enable sprite 1
        lda #$01
        sta $d015

        ; set x,y position 80 = 128/128
        lda #$80
        sta $d000
        sta $d001

LOOP    
        ; wait for scanline
        lda $d012
        cmp $d012
        bne *-3   ;check *until* we're at the target raster line
        ; input check
        jsr check_w
        jsr check_a
        jsr check_s
        jsr check_d
        jmp LOOP

; movement routines
check_w                 
        lda #%11111101  ; select row 2
        sta pra 
        lda prb         ; load column information
        and #%00000010  ; test 'w' key  
        beq go_up
        rts

check_a
        lda #%11111101  ; select row 2
        sta pra 
        lda prb         ; load column information
        and #%00000100  ; test 'a' key  
        beq go_left
        rts

check_s
        lda #%11111101  ; select row 2
        sta pra 
        lda prb         ; load column information
        and #%00100000  ; test 's' key  
        beq go_down
        rts

check_d
        lda #%11111011  ; select row 3
        sta pra 
        lda prb         ; load column information
        and #%00000100  ; test 'd' key  
        beq go_right
        rts

go_up                 
        lda $d001
        cmp #$00        ; check Y-coord whether we are too high
        beq @skip       ; if top of screen reached, skip
        dec $d001       ; increase y-coord for sprite 1
@skip
        rts

go_down
        lda $d001
        cmp #$ff
        beq @skip
        inc $d001
@skip
        rts

go_right                
        lda $d000
        cmp #$ff   
        beq @skip
        inc $d000
@skip
        rts

go_left
        lda $d000
        cmp #$00
        beq @skip
        dec $d000
@skip
        rts


*=$2000
        INCBIN "sprite.spt",1,1