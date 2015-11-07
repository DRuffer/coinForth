;C C@     c-addr -- char   fetch char from memory
        CODEHEADER(XT_CFETCH,2,"c@")
        MOV.B   @TOS,TOS
        NEXT
