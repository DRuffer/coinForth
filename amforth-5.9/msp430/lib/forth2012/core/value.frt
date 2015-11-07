\ the value (in RAM)

: value ( n -- )
    (value)
    here , \ compile the RAM address 
    ['] @ ,
    ['] ! ,
    here ! 2 allot
;
