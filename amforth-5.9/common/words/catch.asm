; ( i*x xt -- j*x 0 | i*x n )
; Exceptions
; execute XT and check for exceptions.

.if cpu_msp430==1
    HEADER(XT_CATCH,5,"catch",DOCOLON)
.endif

.if cpu_avr8==1
VE_CATCH:
    .dw $ff05
    .db "catch",0
    .dw VE_HEAD
    .set VE_HEAD = VE_CATCH
XT_CATCH:
    .dw DO_COLON
PFA_CATCH:
.endif

    ; sp@ >r
    .dw XT_SP_FETCH
    .dw XT_TO_R
    ; handler @ >r
    .dw XT_HANDLER
    .dw XT_FETCH
    .dw XT_TO_R
    ; rp@ handler !
    .dw XT_RP_FETCH
    .dw XT_HANDLER
    .dw XT_STORE
    .dw XT_EXECUTE
    ; r> handler !
    .dw XT_R_FROM
    .dw XT_HANDLER
    .dw XT_STORE
    .dw XT_R_FROM
    .dw XT_DROP
    .dw XT_ZERO
    .dw XT_EXIT
