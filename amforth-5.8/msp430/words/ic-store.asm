;Z IC!        x a-addr --   store char in Instruction memory
        CODEHEADER(XT_CSTOREI,3,"c!i")
        MOV     @PSP+,W         ; get data to write
        CMP.B   @TOS,W
        JZ      IST_X           ; if memory is desired value, do not write
        ; is it within Main flash?
        CMP     #FLASHSTART,TOS
        JNC     ICST_INFO       ; if borrow, adr<start, check if Info
        CMP     #FLASHEND+1,TOS
        JNC     ICST_OK         ; if no borrow, adr>end, check if Info
ICST_INFO: ; is it within Info flash?
        CMP     #INFOSTART,TOS
        JNC     ICST_RAM        ; if borrow, adr<start, assume it's RAM
        CMP     #INFOEND+1,TOS
        JC      ICST_RAM        ; if no borrow, adr>end, assume it's RAM
ICST_OK: ; Address is either in Main flash, or in Info flash.
        ; Byte/word write from flash. 
        ; Assumes location to write is already erased
        ; Assumes ACCVIE = NMIIE = OFIE = 0, watchdog disabled.
        ; Per section 5.3.3 of MSP430 Family User's Guide
        DINT                    ; Disable interrupts
        MOV #FWKEY,&FCTL3       ; Clear LOCK
        MOV #FWKEY+WRT,&FCTL1   ; Enable write
ICST_RAM: ; If RAM, jump here to write.  FCTL1,FCTL3,EINT are superfluous
        MOV.B   W,0(TOS)        ; Write byte to flash location
        MOV #FWKEY,&FCTL1       ; Done. Clear WRT.
        MOV #FWKEY+LOCK,&FCTL3  ; Set LOCK
        EINT                    ; Enable interrupts
        JMP     IST_X
