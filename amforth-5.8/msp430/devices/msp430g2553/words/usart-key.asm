;C KEY      -- c      get character from keyboard
        CODEHEADER(XT_KEY,3,"key")
KEYLOOP:
        BIT.B   #UCA0RXIFG,&IFG2
        JZ      KEYLOOP
        SUB     #2,PSP          ; 1  push old TOS..
        MOV     TOS,0(PSP)      ; 4  ..onto stack
        MOV.B   &UCA0RXBUF,TOS
donext: NEXT
