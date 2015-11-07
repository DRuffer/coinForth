
: [else]     \ ( -- )
    begin
        begin
            parse-name 
            dup
        while
            2dup s" [else]" icompare
            ?dup 0=
            if exit then
        repeat 2drop
        refill 0=
    until
; immediate

: [if]     \ ( flag -- )
    0= if postpone [else] then
; immediate

: [then] ; immediate
