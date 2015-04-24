;C DOES>    --      change action of latest def'n
;   COMPILE (DOES>)
;   dodoes ,JMP ; IMMEDIATE
; Note that MSP430 uses a JMP, not a CALL, to DODOES.
    IMMED(DOES,5,"does>",DOCOLON)
        DW XT_COMPILE,XT_DODOES
	DW XT_COMPILE,4030h   ; compile a machine jump instruction
        DW XT_COMPILE,dodoes
	DW XT_EXIT
