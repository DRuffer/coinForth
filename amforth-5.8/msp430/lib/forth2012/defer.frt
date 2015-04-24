\ msp430 is close the standard reference implementation
\ well, almost ;)

\ defers reside in RAM, they need to be re-assigned
\ at startup.

: defer <builds here , 2 allot does> @i @ execute ;
: defer@ >body @i @ ;
: defer! >body @i ! ;

