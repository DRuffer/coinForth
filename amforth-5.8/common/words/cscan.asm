; ( addr1 n1 c -- addr1 n2 ) 
; String
; Scan string at addr1/n1 for the first occurance of c, leaving addr1/n2, char at n2 is first non-c character

.if cpu_msp430==1
    HEADER(XT_CSCAN,5,"cscan",DOCOLON)
.endif

.if cpu_avr8==1
VE_CSCAN:
    .dw $ff05
    .db "cscan"
    .dw VE_HEAD
    .set VE_HEAD = VE_CSCAN
XT_CSCAN:
    .dw DO_COLON
PFA_CSCAN:
.endif
    .dw XT_TO_R
    .dw XT_OVER
PFA_CSCAN1:
    .dw XT_DUP
    .dw XT_CFETCH
    .dw XT_R_FETCH
    .dw XT_EQUAL
    .dw XT_ZEROEQUAL
    .dw XT_DOCONDBRANCH
    DEST(PFA_CSCAN2)
      .dw XT_SWAP
      .dw XT_1MINUS
      .dw XT_SWAP
      .dw XT_OVER
      .dw XT_ZEROLESS ; not negative
      .dw XT_ZEROEQUAL
      .dw XT_DOCONDBRANCH
      DEST(PFA_CSCAN2)
        .dw XT_1PLUS
        .dw XT_DOBRANCH
        DEST(PFA_CSCAN1)
PFA_CSCAN2:
    .dw XT_NIP
    .dw XT_OVER
    .dw XT_MINUS
    .dw XT_R_FROM
    .dw XT_DROP
    .dw XT_EXIT

; : my-cscan ( addr len c -- addr len' )
;    >r over ( -- addr len addr )
;    begin
;      dup c@ r@ <> while
;       swap 1- swap over 0 >=  while
;        1+ 
;     repeat then
;     nip over - r> drop 
; ;
