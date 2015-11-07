; ----------------------------------------------------------------------
; TERMINAL I/O (TARGET-SPECIFIC)

;C EMIT     c --    output character to console
        CODEHEADER(XT_EMIT,4,"emit")
EMITLOOP:
        BIT.B   #UCA0TXIFG,&IFG2
        JZ      EMITLOOP
        MOV.B   TOS,&UCA0TXBUF
        MOV @PSP+,TOS
        NEXT
