        CODEHEADER(XT_EMIT,4,"emit")
EMITLOOP:
        BIT.B   #UTXIFG0,&IFG1
        JZ      EMITLOOP
        MOV.B   TOS,&U0TXBUF
        MOV @PSP+,TOS
        NEXT
