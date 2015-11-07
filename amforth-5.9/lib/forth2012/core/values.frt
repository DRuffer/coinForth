
: Uvalue ( n offs -- )
    (value)
    dup ,
    ['] Udefer@ ,
    ['] Udefer! ,
    up@ + !
;

: Rvalue ( n -- )
    (value)
    here ,
    ['] Rdefer@ ,
    ['] Rdefer! ,
    here ! 2 allot
;
