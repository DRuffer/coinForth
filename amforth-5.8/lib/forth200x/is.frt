
\ *******************************************
\  IS depends on defer!
\ *******************************************

\ #requires postpone.frt

: is 
    state @ if
	postpone ['] postpone defer!
    else
        ' defer!
    then
; immediate
