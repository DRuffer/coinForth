;Z HEADER   ( addr len wid -- nt )     create a Forth word header
; Separate headers model.
    HEADER(XT_HEADER,6,"header",DOCOLON)
        DW XT_COMMA    ; link
        DW XT_DOLITERAL,0FFh,XT_CCOMMA         ; immediate flag - see note below
        DW XT_IHERE,XT_TO_R
        DW XT_SCOMMA
	DW XT_R_FROM
        DW XT_EXIT   ; MSP430: headers in I space must be aligned
; Note for Flashable MSP430: when compiling to RAM, we need to set
; the immediate byte to 0FFH.  When compiling to Flash, the word IC!
; will not write 0FFH to erased Flash (because the byte is already 0FFH).
; Thus we can write this byte at a later time (with IMMEDIATE).
