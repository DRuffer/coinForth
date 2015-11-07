;X KEY?     -- f    return true if char waiting
        CODEHEADER(XT_KEYQ,4,"key?")
        SUB     #2,PSP          ; 1  push old TOS..
        MOV     TOS,0(PSP)      ; 4  ..onto stack
        BIT.B   #URXIFG0,&IFG1
        JNZ     TOSTRUE
        JMP     TOSFALSE

