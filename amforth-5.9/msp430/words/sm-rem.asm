;C SM/REM   d1 n1 -- n2 n3   symmetric signed div
;   2DUP XOR >R              sign of quotient
;   OVER >R                  sign of remainder
;   ABS >R DABS R> UM/MOD
;   XT_SWAP R> ?NEGATE
;   XT_SWAP R> ?NEGATE ;
; Ref. dpANS-6 section 3.2.2.1.
    HEADER(SMSLASHREM,6,"sm/rem",DOCOLON)
        DW XT_2DUP,XT_XOR,XT_TO_R,XT_OVER,XT_TO_R
        DW XT_ABS,XT_TO_R,XT_DABS,XT_R_FROM,XT_UMSLASHMOD
        DW XT_SWAP,XT_R_FROM,XT_QNEGATE,XT_SWAP,XT_R_FROM,XT_QNEGATE
        DW XT_EXIT
