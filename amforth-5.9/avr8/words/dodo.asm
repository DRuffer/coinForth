; ( limit start -- ) (R: -- loop-sys )
; System
; runtime of do
;VE_DODO:
;    .dw $ff04
;    .db "(do)"
;    .dw VE_HEAD
;    .set VE_HEAD = VE_DODO
XT_DODO:
    .dw PFA_DODO
PFA_DODO:
    ld temp2, Y+
    ld temp3, Y+  ; limit
PFA_DODO1:
    ldi zl, $80
    add temp3, zl
    sub  tosl, temp2
    sbc  tosh, temp3

    push temp3
    push temp2    ; limit  ( --> limit + $8000)
    push tosh
    push tosl     ; start -> index ( --> index - (limit - $8000)
    loadtos
    jmp_ DO_NEXT
