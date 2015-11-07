
\ various defer definitions
\ platform specific examples are available !

\ place the XT in RAM, suitable for frequent changes
\ but needs to be initialized at startup

: Rdefer ( "name" -- )
    here , 
    ['] Rdefer@ ,
    ['] Rdefer! ,
    2 allot
;

\ use the user area to hold the XT. Similiar to
\ Rdefer but task lokal in multitasking applications
: Udefer ( u "name" -- )
    (defer)
    , \ 
    ['] Udefer@ ,
    ['] Udefer! ,
;
