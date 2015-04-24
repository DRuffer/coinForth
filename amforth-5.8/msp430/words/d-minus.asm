;C d+     d1/ud1 d2/ud2 -- d3/ud3 sub d1-d2
;  d1-lo   d1-hi      d2-lo    d2-hi -- d3-lo    d3 -hi
;  4(PSP)  2(PSP)     @(PSP)   TOS   -- NOS      TOS

        CODEHEADER(XT_DMINUS,2,"d-")
        MOV     @PSP,W          ; move content of NOS to workregister
        MOV     4(PSP),X        ; move content of 4th item to scratchregister X
        SUB     W,X             ; subtract contents of scratchregister X from workregister, result is in scratchregister X
        MOV     X,4(PSP)        ; store result in 4th item
        SUBC    TOS,2(PSP)      ; subtract content of TOS from the 3rd item, result is in 3rd item  
        MOV     2(PSP),TOS      ; move contoent of 3rd item to TOS
        ADD     #4,PSP          ; adjust parameterstackpointer, i.e. nip nip
        NEXT
