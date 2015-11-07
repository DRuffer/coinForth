;C EXECUTE   i*x xt -- j*x   execute Forth word
;C                           at 'xt'
        CODEHEADER(XT_EXECUTE,7,"execute")
        MOV TOS,W       ; 1 put word address into W
        MOV @PSP+,TOS   ; 2 fetch new TOS
        MOV @W+,PC      ; 2 fetch code address into PC, W=PFA

