;C >R    x --   R: -- x   push to return stack
        CODEHEADER(XT_TO_R,2,">r")
        PUSH TOS
        MOV @PSP+,TOS
        NEXT
