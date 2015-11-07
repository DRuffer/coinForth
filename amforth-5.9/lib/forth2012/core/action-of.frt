\ *******************************************
\  action-of depends on defer@
\ *******************************************

\ #requires postpone.frt

: action-of
    state @
    if
       postpone ['] postpone defer@
    else
       ' defer@
    then
; immediate
