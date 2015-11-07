;C NEGATE   x1 -- x2            two's complement
        CODEHEADER(XT_NEGATE,6,"negate")
        XOR     #-1,TOS
        ADD     #1,TOS
        NEXT
