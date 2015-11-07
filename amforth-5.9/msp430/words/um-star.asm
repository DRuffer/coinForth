;C UM*     u1 u2 -- ud   unsigned 16x16->32 mult.
        CODEHEADER(XT_UMSTAR,3,"um*")
        ; IROP1 = TOS register
        MOV     @PSP,IROP2L     ; get u1, leave room on stack
;
; T.I. SIGNED MULTIPLY SUBROUTINE: IROP1 x IROP2L -> IRACM|IRACL
MPYU:   CLR IRACL ; 0 -> LSBs RESULT
        CLR IRACM ; 0 -> MSBs RESULT
; UNSIGNED MULTIPLY AND ACCUMULATE SUBROUTINE:
; (IROP1 x IROP2L) + IRACM|IRACL -> IRACM|IRACL
MACU:   CLR IROP2M  ; MSBs MULTIPLIER
        MOV #1,IRBT ; BIT TEST REGISTER
L_002:  BIT IRBT,IROP1 ; TEST ACTUAL BIT
        JZ L_01     ; IF 0: DO NOTHING
        ADD IROP2L,IRACL ; IF 1: ADD MULTIPLIER TO RESULT
        ADDC IROP2M,IRACM
L_01:   RLA IROP2L  ; MULTIPLIER x 2
        RLC IROP2M
;
        RLA IRBT    ; NEXT BIT TO TEST
        JNC L_002   ; IF BIT IN CARRY: FINISHED
; END T.I. ROUTINE  section 5.1.1 of MSP430 Family Application Reports
        MOV     IRACL,0(PSP)    ; low result on stack
        MOV     IRACM,TOS       ; high result in TOS
        NEXT

