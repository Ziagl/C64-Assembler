*=$0801
        BYTE  $0B, $08, $0A, $00, $9E, $32, $30, $36, $34, $00, $00, $00

*=$0810

        jsr init_screen
        jsr init_text
        jsr scroll_text

;LOOP    jmp LOOP



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

scroll_text
        lda $d016       ; Register 22 in den Akku
        and #%11110000  ; Bits für den Offset vom linken Rand löschen
        ora scrollpos   ; neuen Offset setzen
        sta $d016       ; und zurück ins VIC-II-Register schreiben

        ; dieser Block synchronisiert mit Bildaufbau
        lda #200        ; Rasterzeile 200
        cmp $d012       ; mit der aktuellen Rasterzeile vergleichen
        beq *-3         ; solange diese identisch sind -> warten
        cmp $d012       ; wieder mit der aktuellen Zeile vergleichen
        bne *-3         ; solange diese unterschiedlich sind -> warten

        inc scrollpos   ; Offset um 1 erhöhen
        lda #%00000111  ; man braucht nur die unteren drei BITs
        and scrollpos   ; also ausmaskieren
        sta scrollpos   ; und speichern
        bne scroll_text ; falls der Offset NICHT 0 ist -> main
        jsr moveRow     ; sonst die Zeile umkopieren

        ; dieser Block lässt die verschwundenen Zeichen auf der anderen Seite erscheinen
        ldx scrollTextPos   ; Position des nächsten Zeichen 
        lda line1,X         ; Zeichen in den Akku holen
        sta $0400+$190      ; Zeichen ausgeben
        lda line2,X         ; selber Code füt line2
        sta $0400+$1E0
        dex
        beq restart
        stx scrollTextPos   ; und speichern
        jmp scroll_text     ; auf ein Neues
restart
        sta scrollTextPos   ; Posi. des nächsten Zeichens auf 0 zurücksetzen

        jmp scroll_text     ; auf ein Neues

moveRow                 
        ldx #39             ; 40 Zeichen je Zeile
nextChar
        lda $0400+$18F,X    ; 'vorheriges' Zeichen holen line1
        sta $0400+$190,X    ; ins aktuelle kopieren
        lda $0400+$1DF,X    ; selber Code für line2
        sta $0400+$1E0,X
        dex                 ; Schleifenzähler verringern
        bne nextChar        ; solange nicht 0 -> nextChar
        rts                 
 
scrollpos
        byte 0              ; aktuelle Scrollposition

scrollTextPos
        byte $0400+40       ; nächstes Zeichen aus dem scrolltext
