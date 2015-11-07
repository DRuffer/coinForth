; ( ud1 c-addr1 u1 -- ud2 c-addr2 u2 ) 
; Numeric IO
; convert a string to a number  c-addr2/u2 is the unconverted string

.if cpu_msp430==1
    HEADER(XT_TO_NUMBER,7,">number",DOCOLON)
.endif

.if cpu_avr8==1
VE_TO_NUMBER:
    .dw $ff07
    .db ">number",0
    .dw VE_HEAD
    .set VE_HEAD = VE_TO_NUMBER
XT_TO_NUMBER:
    .dw DO_COLON

.endif

TONUM1: .DW XT_DUP,XT_DOCONDBRANCH
        DEST(TONUM3)
        .DW XT_OVER,XT_CFETCH,XT_DIGITQ
        .DW XT_ZEROEQUAL,XT_DOCONDBRANCH
        DEST(TONUM2)
        .DW XT_DROP,XT_EXIT
TONUM2: .DW XT_TO_R,XT_2SWAP,XT_BASE,XT_FETCH,XT_UDSTAR
        .DW XT_R_FROM,XT_MPLUS,XT_2SWAP
        .DW XT_DOLITERAL,1,XT_SLASHSTRING,XT_DOBRANCH
        DEST(TONUM1)
TONUM3: .DW XT_EXIT

;C >NUMBER  ud adr u -- ud' adr' u'
;C                      convert string to number
;   BEGIN
;   DUP WHILE
;       OVER C@ DIGIT?
;       0= IF DROP EXIT THEN
;       >R 2SWAP BASE @ UD*
;       R> M+ 2SWAP
;       1 /STRING
;   REPEAT ;
