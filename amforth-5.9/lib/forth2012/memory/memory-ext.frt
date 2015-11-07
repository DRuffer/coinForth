
: size 
    1- @ cells
;

     variable freelist 0 freelist !
1024 constant size-freelist

\ empty the dynamic pool
: clobber
    size-freelist 1- freelist ! 0 freelist 1+ !
;

\ allocate at load-time
size-freelist 1- cells allot clobber

: next-chunk
    1+ 
;

: adjacent-chunk
    dup @ 1+ + ;
;

: find-chunk
    freelist
    begin
	dup
    while
	over 2 + over @ >
    while
	next-chunk @
    repeat
    then 
    nip
;

: split-chunk
    >r dup dup  @ r@ 1+ - dup rot ! 1+ + r> over !
;

: merge-chunks
    @ 1+ swap +!
;

: merge-free-chunks
    over over merge-chunks 1+ @ swap 1+ !
;

\ **************

: allocate
    dup find-chunk dup
    if
	swap split-chunk 1+
    else
	nip
	-268
    then
;

: free
    dup 0= if drop exit then
    
;