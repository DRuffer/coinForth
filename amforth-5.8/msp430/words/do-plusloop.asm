;Z (+loop)   n --   R: sys1 sys2 --  | sys1 sys2
;Z                        run-time code for +LOOP
; Add n to the loop index.  If loop terminates, clean up the 
; return stack and skip the branch. Else take the inline branch.
;        ; CODEHEADER(xplusloop,7,"(+loop)")
;        DW      link
;        DB      0FFh       ; not immediate
;.set link = $
;        DB      7,"(+loop)"
;        .align 16
XT_DOPLUSLOOP:
	DW     $+2
        ADD     TOS,INDEX
        MOV     @PSP+,TOS   ; get new TOS, doesn't change flags
        BIT     #100h,SR    ; is overflow bit set?
        JZ      dobran    ; no overflow = loop
        ADD     #2,IP       ; overflow = loop done, skip branch ofs
        MOV     @RSP+,INDEX ; restore old loop values
        MOV     @RSP+,LIMIT
        NEXT
