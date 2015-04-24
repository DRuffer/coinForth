; ( n1 n2 -- n1|n2 ) 
; Compare
; compare two values, leave the bigger one

.if cpu_msp430==1
    HEADER(XT_MAX,3,"max",DOCOLON)
.endif

.if cpu_avr8==1
VE_MAX:
    .dw $ff03
    .db "max",0
    .dw VE_HEAD
    .set VE_HEAD = VE_MAX
XT_MAX:
    .dw DO_COLON
PFA_MAX:

.endif
    .dw XT_2DUP
    .dw XT_LESS
    .dw XT_DOCONDBRANCH
    DEST(PFA_MAX1)
    .dw XT_SWAP
PFA_MAX1:
    .dw XT_DROP
    .dw XT_EXIT
