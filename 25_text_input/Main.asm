; auto generated sys (Tools->Generate Sys() Call)
; 10 SYS (4096)
*=$0801
        BYTE    $0E, $08, $0A, $00, $9E, $20, $28,  $34, $30, $39, $36, $29, $00, $00, $00

; start address of program in memory 0x1000 = 4096)
*=$1000

; source:
; https://technocoma.blogspot.com/p/understanding-6502-assembly-on_63.html

; kernal functions
CHROUT = $ffd2          ; print character
SCNKEY = $ff9f          ; scan keyboard for keypress
GETIN = $ffe4           ; get input from buffer, store it in A

; variables
BLNSW = $cc             ; cursor blink switch
PLOT = $FFF0            ; set/read cursor location
BTCOUNTER = $033f       ; what digit were up to
OURHEXNUM = $033c       ; where the constant OURHEXVALUE will be stored
TESTBYTE = $0345        ; where our test byte will be stored for lsr
BIT7 = $0708            ; the location of the 7th bit, required room for
                        ; 8 contiguous bytes after the starting address
                        ; using 0708 dumps it right to screen ram, bottom center
LOWBYTE = $033d         ; first digit input storage
HIGHBYTE = $033e        ; second digit input storage

INIT                    ; clear screen
        lda #$93
        jsr CHROUT

START                   ; start of main program
        ldy #$80
        sty TESTBYTE
        ldx #$00
        stx BLNSW       ; keeps cursor blinking for inputs
        stx BTCOUNTER
        jsr WRITEPROMPT
        jmp SCANKBD

END
        rts

SCANKBD                 ; get character from keyboard
        jsr SCNKEY
        jsr GETIN
        cmp #$51        ; Q ends endless loop
        beq END
        cmp #$30        ; ignore hex value of < 0
        bcc SCANKBD
        cmp #$3A        ; 0 < 9 -> convert digit
        bcc DIGITCONVERT
        cmp #$41        ; ignore hex value of < A
        bcc SCANKBD
        cmp #$47        ; A < F -> convert letter
        bcc LETTERCONVERT
        jmp SCANKBD

LETTERCONVERT
        jsr CHROUT      ; print the digit before we mess with it
        sbc #$36        ; subtracts hex value 2F to attain actual value in memory 
        jmp MAINCONVERT ; jump to MAINCONVERT after performing the routine

DIGITCONVERT
        jsr CHROUT      ; print the digit to screen before we mess with it
        sbc #$2f        ; subtracts Hex value 2F to attain actual value in memory
                        ; the program will flow right to MAINCONVERT after
                        ; finishing this routine, so why not put it just above
                        ; MAINCONVERT and save the program the space and cycles 
                        ; of running a jmp MAINCONVERT. LETTERCONVERT doesnt have
                        ; this luxury, but there are 10 numbers and only six letters
                        ; so the logical choice is to keep DIGITCONVERT
                        ; just above MAINCONVERT

MAINCONVERT
        ldy BTCOUNTER   ; load Y with current BYTE counter
        cpy #$01        ; are we on the second byte , LSB 
        beq PROCESS     ; yes, leave the converted byte alone and go back to PROCESS  
        asl             ; shift the binary value to the left four times           
        asl             ; turns 01 into 10, 02 into 20, 03 into 30 etc etc etc
        asl             ; just a nifty trick, so long as nothing exceeds FF     
        asl             ; which it wont, highest possible total os F0
        jmp PROCESS     ; jump back to process

PROCESS
        ldx BTCOUNTER   ; put out BYTECOUNTER in X
        sta LOWBYTE,x   ; places our values in LOWBYTE and HIGHBYTE
        inx             ; incremet the BYTECOUNTER by 1
        stx BTCOUNTER   ; and store the new value in BYTECOUNTER
        cpx #$02        ; if BYTECOUNTER is $02 were done adding values
        bne SCANKBD     ; not 2, keep scannig for inputs

;;;;;  If we are right here, it means we now have our two bytes, we must
;;;;;  Add them together to get our final HEX value to convert to binary
;;;;;  We will store final value in OURHEXNUM and jump to SETCONVERT
        clc
        lda LOWBYTE     ; load the low byte into A
        adc HIGHBYTE    ; add the high byte to it
        sta OURHEXNUM   ; store out final value in OURHEXNUM for processing
        jmp SETCONVERT  ; jump the conversion portion of our program

SETCONVERT
        ldx #$00         ; initialize X for loop

CONVERTION
        lda OURHEXNUM    ; load our test hex number, this is a constant
        and TESTBYTE     ; mask it with our test byte
        cmp #$00         ; is the result 00?
        bne STORE1       ; no, jsr to STORE1
        lda #$30         ; load the display value of 0 into A
        jmp CONTINUE

STORE1
        lda #$31         ; Load the display value of 1 into A

CONTINUE
        sta BIT7,x       ; load the display value into A
        inx              ; increment X for loop
        lda TESTBYTE     ; load testbyte into A                                                                                                                              
        lsr              ; divide it by 2
        sta TESTBYTE     ; store new testbyte back to its memory area
        cpx #$08         ; is X=8?
        bne CONVERTION   ; no, LOOP back to CONVERSION

;;;;;;;;; BLANK THE TWO DIGITS, SET CURSOR TO THE ORIGINAL POSITION OF INPUT
;;;;;;;;; 
        lda #$20        ; load a blank space value into A
        sta $0413       ; store it into our input numbers to blank it out
        sta $0414       ; for the next set of inputs
        clc             ; clear any latent carry flags just to be safe
        ldx #$00        ; set X for top line
        ldy #$00        ; set Y for first character
        jsr PLOT        ; move cursor
        jmp START       ; repeat the whole process again from START

WRITEPROMPT             ; prints PROMPT
        lda PROMPT,x
        beq END1
        jsr CHROUT
        inx
        jmp WRITEPROMPT
END1
        rts
        
PROMPT
        ptext "> "       ; PROMPT with 2 byte length
        byte 00