;C INVERT   x1 -- x2            bitwise inversion
        CODEHEADER(XT_INVERT,6,"invert")
        XOR     #-1,TOS
        NEXT
