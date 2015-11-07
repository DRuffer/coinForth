;C UNLOOP   --   R: sys1 sys2 --  drop loop parms
        CODEHEADER(XT_UNLOOP,6,"unloop")
        MOV     @RSP+,INDEX     ; restore old loop values
        MOV     @RSP+,LIMIT
        NEXT
