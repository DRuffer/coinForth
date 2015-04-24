
;C XOR    x1 x2 -- x3            logical XOR
        CODEHEADER(XT_XOR,3,"xor")
        XOR     @PSP+,TOS
        NEXT
