;Z I!        x a-addr --   store cell in Instruction memory
        CODEHEADER(XT_STOREI,2,"!i")
        MOV     @PSP+,W         ; get data to write
        BIT     #1,TOS
        JNZ     IST_X           ; if not even address, do not write
        CMP     @TOS,W
        JZ      IST_X           ; if memory is desired value, do not write
        ; is it within Main flash?
        CMP     #FLASHSTART,TOS
        JNC     IST_INFO        ; if borrow, adr<start, check if Info
        CMP     #FLASHEND+1,TOS
        JNC     IST_OK          ; if no borrow, adr>end, check if Info
IST_INFO: ; is it within Info flash?
        CMP     #INFOSTART,TOS
        JNC     IST_RAM         ; if borrow, adr<start, assume it's RAM
        CMP     #INFOEND+1,TOS
        JC      IST_RAM         ; if no borrow, adr>end, assume it's RAM
IST_OK: ; Address is either in Main flash, or in Info flash.
        ; Byte/word write from flash. 
        ; Assumes location to write is already erased
        ; Assumes ACCVIE = NMIIE = OFIE = 0, watchdog disabled.
        ; Per section 5.3.3 of MSP430 Family User's Guide
        DINT                    ; Disable interrupts
        MOV #FWKEY,&FCTL3       ; Clear LOCK
        MOV #FWKEY+WRT,&FCTL1   ; Enable write
IST_RAM: ; If RAM, jump here to write.  FCTL1,FCTL3,EINT are superfluous
        MOV     W,0(TOS)        ; Write word to flash location
        MOV #FWKEY,&FCTL1       ; Done. Clear WRT.
        MOV #FWKEY+LOCK,&FCTL3  ; Set LOCK
        EINT                    ; Enable interrupts
IST_X:  MOV     @PSP+,TOS       ; pop new TOS
        NEXT
