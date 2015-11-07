;Z uinit    -- addr  initial values for user area
; MSP430: we also use this to initialize the RAM interrupt
; vectors, which immediately follow the user area.
; Per init430f1611.s43, allocate 16 cells for user
; variables, followed by 30 cells for interrupt vectors.
    HEADER(UINIT,5,"uinit",DOROM)
; CFG Area
	DW 2,XT_REC_WORD,XT_REC_NUM,0,0
	DW 1,XT_LATEST,0,0,0,0,0,0,0
	DW XT_NOOP      ; PAUSE vector
	DW XT_APPLTURNKEY ; TURNKEY vector
; USER Area
        DW 0,0,10,0     ; reserved,>IN,XT_BASE,STATE
        DW RAMDICT      ; DP
        DW 0,0          ; SOURCE init'd elsewhere
        DW lastword     ; LATEST
        DW 0,0          ; HP,LP init'd elsewhere
        DW ROMDICT      ; IDP
        DW 0            ; NEWEST not init'd
	DW 0            ; HANDLER not init'd
	DW lastenv      ; environment wordlist
        DW XT_APPLTURNKEY   ; TURNKEY
	DW 0,0,0        ; user variables TBD

    ; RAM interrupt vectors, 15 vectors of 2 cells each
        MOV #nullirq,PC
        MOV #nullirq,PC
        MOV #nullirq,PC
        MOV #nullirq,PC
        MOV #nullirq,PC
        MOV #nullirq,PC
        MOV #nullirq,PC
        MOV #nullirq,PC
        MOV #nullirq,PC
        MOV #nullirq,PC
        MOV #nullirq,PC
        MOV #nullirq,PC
        MOV #nullirq,PC
        MOV #nullirq,PC
        MOV #nullirq,PC
