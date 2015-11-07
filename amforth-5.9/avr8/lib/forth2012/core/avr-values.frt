

\ EEPROM based values

: Evalue ( n -- )
    (value)
    ehere ,
    ['] Edefer@ ,
    ['] Edefer! ,
    ehere dup cell+ to ehere !e
;
