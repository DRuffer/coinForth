; ( -- ) 
; Tools
; print the version string

.if cpu_msp430==1
   HEADER(XT_DOT_VER,3,"ver",DOCOLON)
.endif

.if cpu_avr8==1
VE_DOT_VER:
    .dw $ff03
    .db "ver"
    .dw VE_HEAD
    .set VE_HEAD = VE_DOT_VER
XT_DOT_VER:
    .dw DO_COLON
PFA_DOT_VER:
.endif
    .dw XT_ENV_FORTHNAME
    .dw XT_ITYPE
    .dw XT_SPACE
    .dw XT_BASE
    .dw XT_FETCH

    .dw XT_ENV_FORTHVERSION
    .dw XT_DECIMAL
    .dw XT_S2D
    .dw XT_L_SHARP
    .dw XT_SHARP
    .dw XT_DOLITERAL
    .dw '.'
    .dw XT_HOLD
    .dw XT_SHARP_S
    .dw XT_SHARP_G
    .dw XT_TYPE
    .dw XT_BASE
    .dw XT_STORE
    .dw XT_SPACE
    .dw XT_ENV_CPU
    .dw XT_ITYPE

    .dw XT_EXIT
