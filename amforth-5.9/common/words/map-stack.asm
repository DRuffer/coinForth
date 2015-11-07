; ( i*x XT e-addr -- j*y true | i*x false ) 
; Tools
; Iterate over a stack

.if cpu_msp430==1
    HEADER(XT_MAPSTACK,9,"map-stack",DOCOLON)
.endif

.if cpu_avr8==1
VE_MAPSTACK:
    .dw $ff09
    .db "map-stack",0
    .dw VE_HEAD
    .set VE_HEAD = VE_MAPSTACK
XT_MAPSTACK:
    .dw DO_COLON
PFA_MAPSTACK:
.endif
    .dw XT_DUP
    .dw XT_CELLPLUS
    .dw XT_SWAP
    .dw XT_FETCHE
    .dw XT_CELLS
    .dw XT_BOUNDS
    .dw XT_QDOCHECK
    .dw XT_DOCONDBRANCH
    DEST(PFA_MAPSTACK3)
    .dw XT_DODO
PFA_MAPSTACK1:
      .dw XT_I
      .dw XT_FETCHE   ; -- i*x XT id
      .dw XT_SWAP
      .dw XT_TO_R
      .dw XT_R_FETCH
      .dw XT_EXECUTE  ; i*x id -- j*y true | i*x false
      .dw XT_QDUP
      .dw XT_DOCONDBRANCH
      DEST(PFA_MAPSTACK2)
         .dw XT_R_FROM
         .dw XT_DROP
         .dw XT_UNLOOP
         .dw XT_EXIT
PFA_MAPSTACK2:
      .dw XT_R_FROM
      .dw XT_DOLITERAL
      .dw 2
      .dw XT_DOPLUSLOOP
      DEST(PFA_MAPSTACK1)
PFA_MAPSTACK3:
    .dw XT_DROP
    .dw XT_ZERO
    .dw XT_EXIT

;
; : map-stack ( i*x XT e-addr -- j*y )
;     dup cell+ swap @e cells bounds ?do 
;       ( -- i*x XT )
;       i @e swap >r r@ execute
;       ?dup if r> drop unloop exit then
;       r>
;     2 +loop drop 0
;
