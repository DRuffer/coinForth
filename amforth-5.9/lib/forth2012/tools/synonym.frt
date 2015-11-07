\ SYNONYM <newname> <oldname>

\
\ does not check for reference to itself
\
: synonym 
    create immediate ' ,
  does>
    @i state @ if , else execute then
;

\ : synonym : bl word find >r compile, postpone ; r> 0> IF immedate THEN ;