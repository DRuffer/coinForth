;Z ?branch   x --              branch if TOS zero
        CODEHEADER(XT_DOCONDBRANCH,7,"?branch")
        ADD #0,TOS      ; 1  test TOS value
        MOV @PSP+,TOS   ; 2  pop new TOS value (doesn't change flags)
        JZ  dobran    ; 2  if TOS was zero, take the branch
        ADD #2,IP       ; 1  else skip the branch destination
        NEXT            ; 4
