;Z (do)    n1|u1 n2|u2 --  R: -- sys1 sys2
;Z                          run-time code for DO
; '83 and ANSI standard loops terminate when the boundary of 
; limit-1 and limit is crossed, in either direction.  This can 
; be conveniently implemented by making the limit 8000h, so that
; arithmetic overflow logic can detect crossing.  I learned this 
; trick from Laxen & Perry F83.
; fudge factor = 8000h-limit, to be added to the start value.
;        ; CODEHEADER(xdo,4,"(do)")
;        DW      link
;        DB      0FFh       ; not immediate
;.set link = $
;        DB      4,"(do)"
;        .align 16
XT_DODO:
xdo: DW     $+2       
        SUB     #4,RSP          ; push old loop values on return stack
        MOV     LIMIT,2(RSP)
        MOV     INDEX,0(RSP)
        MOV     #8000h,LIMIT    ; compute 8000h-limit "fudge factor"
        SUB     @PSP+,LIMIT
        MOV     TOS,INDEX       ; loop ctr = index+fudge
        ADD     LIMIT,INDEX
        MOV     @PSP+,TOS       ; pop new TOS
        NEXT
