;Z (loop)   R: sys1 sys2 --  | sys1 sys2
;Z                        run-time code for LOOP
; Add 1 to the loop index.  If loop terminates, clean up the 
; return stack and skip the branch.  Else take the inline branch.  
; Note that LOOP terminates when index=8000h.
;        ; CODEHEADER(xloop,6,"(loop)")
;        DW      link
;        DB      0FFh       ; not immediate
;.set link = $
;        DB      6,"(loop)"
;        .align 16
XT_DOLOOP:
	DW     $+2
        ADD     #1,INDEX
        BIT     #100h,SR    ; is overflow bit set?
        JZ      dobran    ; no overflow = loop
        ADD     #2,IP       ; overflow = loop done, skip branch ofs
        MOV     @RSP+,INDEX ; restore old loop values
        MOV     @RSP+,LIMIT
        NEXT
