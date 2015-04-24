;C XT_SWAP     x1 x2 -- x2 x1    swap top two items
        CODEHEADER(XT_SWAP,4,"swap")
        MOV     @PSP,W          ; 2
        MOV     TOS,0(PSP)      ; 4
        MOV     W,TOS           ; 1
        NEXT                    ; 4
