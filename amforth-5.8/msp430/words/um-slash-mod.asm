;C UM/MOD   ud u1 -- u2 u3   unsigned 32/16->16
        CODEHEADER(XT_UMSLASHMOD,6,"um/mod")
        ; IROP1 = TOS register
        MOV     @PSP+,IROP2M    ; get ud hi
        MOV     @PSP,IROP2L     ; get ud lo, leave room on stack
;
; T.I. UNSIGNED DIVISION SUBROUTINE 32-BIT BY 16-BIT
; IROP2M|IROP2L : IROP1 -> IRACL REMAINDER IN IROP2M
; RETURN: CARRY = 0: OK CARRY = 1: QUOTIENT > 16 BITS
DIVIDE: CLR IRACL   ; CLEAR RESULT
        MOV #17,IRBT ; INITIALIZE LOOP COUNTER
DIV1:   CMP IROP1,IROP2M ;
        JLO DIV2
        SUB IROP1,IROP2M
DIV2:   RLC IRACL
        JC DIV4     ; Error: result > 16 bits
        DEC IRBT    ; Decrement loop counter
        JZ DIV3     ; Is 0: terminate w/o error
        RLA IROP2L
        RLC IROP2M
        JNC DIV1
        SUB IROP1,IROP2M
        SETC
        JMP DIV2
DIV3:   CLRC        ; No error, C = 0
DIV4:   ; Error indication in C
; END T.I. ROUTINE  Section 5.1.5 of MSP430 Family Application Reports
        MOV     IROP2M,0(PSP)   ; remainder on stack
        MOV     IRACL,TOS       ; quotient in TOS
        NEXT

