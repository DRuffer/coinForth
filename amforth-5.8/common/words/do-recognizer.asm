; (addr len -- i*x r:table | r:fail)
; System
; walk the recognizer stack

.if cpu_msp430==1
    HEADER(XT_DORECOGNIZER,13,"do-recognizer",DOCOLON)
.endif

.if cpu_avr8==1
VE_DORECOGNIZER:
    .dw $ff0d
    .db "do-recognizer",0
    .dw VE_HEAD
    .set VE_HEAD = VE_DORECOGNIZER
XT_DORECOGNIZER:
    .dw DO_COLON
PFA_DORECOGNIZER:
.endif
    .dw XT_DOLITERAL
    .dw XT_DORECOGNIZER_A
    .dw XT_DOLITERAL
    .dw CFG_RECOGNIZERLISTLEN
    .dw XT_MAPSTACK
    .dw XT_ZEROEQUAL
    .dw XT_DOCONDBRANCH
    DEST(PFA_DORECOGNIZER1)
      .dw XT_2DROP
      .dw XT_R_FAIL
PFA_DORECOGNIZER1:
    .dw XT_EXIT

.if cpu_msp430==1
    HEADLESS(XT_DORECOGNIZER_A,DOCOLON)
.endif

.if cpu_avr8==1

; ( addr len XT -- addr len [ r:table -1 | 0 ] )
XT_DORECOGNIZER_A:
   .dw DO_COLON
PFA_DORECOGNIZER_A:
.endif
   .dw XT_ROT  ; -- len xt addr
   .dw XT_ROT  ; -- xt addr len
   .dw XT_2DUP 
   .dw XT_2TO_R
   .dw XT_ROT  ; -- addr len xt
   .dw XT_EXECUTE ; -- i*x r:foo | r:fail
   .dw XT_2R_FROM
   .dw XT_ROT
   .dw XT_DUP
   .dw XT_R_FAIL
   .dw XT_EQUAL
   .dw XT_DOCONDBRANCH
   DEST(PFA_DORECOGNIZER_A1)
     .dw XT_DROP
     .dw XT_ZERO
     .dw XT_EXIT
PFA_DORECOGNIZER_A1:
   .dw XT_NIP 
   .dw XT_NIP
   .dw XT_TRUE
   .dw XT_EXIT

; : do-recognizer ( addr len -- i*x r:table|r:fail )
;    \ ( addr len -- addr len 0 | i*x r:table -1 )
;    [: rot rot 2dup 2>r rot execute 2r> rot 
;          dup r:fail = ( -- addr len r:table f )
;          if drop 0 else nip nip -1 then
;    ;] 
;    EE_RECOGNIZERLISTLEN map-stack ( -- i*x addr len r:table f )
;    0= if \ a recognizer did the job, remove addr/len
;     2drop r:fail 
;    then
;
