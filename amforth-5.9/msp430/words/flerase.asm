;Z FLERASE  a-addr n -- 
        CODEHEADER(XT_FLERASE,7,"flerase")
        MOV     @PSP+,W         ; get address in W
        ADD     W,TOS           ; TOS=end adrs (first unerased adrs)
FLE_1:
        CMP     TOS,W           ; adr-end
        JC      FLE_X           ; if no borrow, adr>=end, do not erase
        ; is it within Main flash?
        CMP     #FLASHSTART,W
        JNC     FLE_INFO        ; if borrow, adr<start, check if Info
        CMP     #FLASHEND+1,W
        JNC     FLE_OK          ; if no borrow, adr>end, check if Info
FLE_INFO: ; is it within Info flash?
        CMP     #INFOSTART,W
        JNC     FLE_X           ; if borrow, adr<start, do not erase
        CMP     #INFOEND+1,W
        JC      FLE_X           ; if no borrow, adr>end, do not erase
FLE_OK: ; Address is either in Main flash, or in Info flash.
        ; Segment Erase from flash. 
        ; Assumes ACCVIE = NMIIE = OFIE = 0, watchdog disabled.
        ; Per section 5.3.2 of MSP430 Family User's Guide
        DINT                    ; Disable interrupts
        MOV #FWKEY,&FCTL3       ; Clear LOCK
        MOV #FWKEY+ERASE,&FCTL1 ; Enable segment erase
        MOV     #-1,0(W)        ; Dummy write in segment to erase
        MOV #FWKEY,&FCTL1       ; Done. Clear erase command.
        MOV #FWKEY+LOCK,&FCTL3  ; Done, set LOCK
        EINT                    ; Enable interrupts
        ; Advance flash pointer by 512 bytes or 128 bytes
        ; is it within Main flash?
        CMP     #FLASHSTART,W
        JNC     FL_INFO         ; if borrow, adr<start, must be Info
        CMP     #FLASHEND+1,W
        JC      FL_INFO         ; if no borrow, adr>end, must be Info
        ADD     #(MAINSEG-INFOSEG),W
FL_INFO: ADD    #INFOSEG,W
        JMP     FLE_1           ; continue till past end or outside limits
FLE_X:  MOV     @PSP+,TOS
        NEXT
