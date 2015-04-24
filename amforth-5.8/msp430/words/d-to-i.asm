;Z D->I     c-addr1 c-addr2 u --  move Data->Code
; Block move from Data space to Code space.  Flashable.
; For the MSP430, this uses a "smart" algorithm that uses word writes,
; rather than byte writes, whenever possible.  Note that byte reads
; are used for the source, so it need not be aligned.
        CODEHEADER(XT_DTOI,4,"d->i")
        MOV     @PSP+,W     ; dest adrs
        MOV     @PSP+,X     ; src adrs
        CMP     #0,TOS
        JZ      DTOI_X
DTOI_LOOP: ; Begin flash write sequence
        DINT                    ; Disable interrupts
        MOV #FWKEY,&FCTL3       ; Clear LOCK
        MOV #FWKEY+WRT,&FCTL1   ; Enable write
        ; If length is 1, or dest. address is odd, do a byte write.
        ; Else, do a word write.
        CMP     #1,TOS
        JZ      DTOI_BYTE
        BIT     #1,W
        JNZ     DTOI_BYTE
DTOI_WORD: MOV.B @X+,Y          ; get low byte of word
        MOV.B   @X+,Q           ; get high byte of word
        SWPB    Q
        BIS     Q,Y             ; merge bytes
        MOV     Y,0(W)          ; write byte to dest 
        ADD     #2,W
        SUB     #1,TOS          ; another 1 will be subtracted below
        JMP     DTOI_END
DTOI_BYTE: MOV.B  @X+,0(W)      ; copy byte from src to dest
        ADD     #1,W
DTOI_END: ; End flash write sequence
        MOV #FWKEY,&FCTL1       ; Done. Clear WRT.
        MOV #FWKEY+LOCK,&FCTL3  ; Set LOCK
        EINT                    ; Enable interrupts
        SUB     #1,TOS
        JNZ     DTOI_LOOP
DTOI_X: MOV     @PSP+,TOS       ; pop new TOS
        NEXT
