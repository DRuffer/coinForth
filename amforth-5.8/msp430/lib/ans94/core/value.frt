\ the value (in RAM)


: (value)
   <builds  \ do nothing but create the header
   does>    \ read and execute the access method
    ( pfa -- )
    dup @i swap i-cell+ @i  execute
;

: value ( n -- )
    (value)
    here , \ compile the RAM address 
    ['] @ ,
    ['] ! ,
    here ! 2 allot
;
