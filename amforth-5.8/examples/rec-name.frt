
\ #require compile-comma.frt
\ #require recognizer.frt

\ from forth 2012
:noname name>interpret execute ;
:noname name>compile execute ;
:noname name>compile swap postpone literal compile, ;
recognizer: r:name

\ helper words
: isword? ( addr len flag nt -- addr len false | nt true )
  >r drop 2dup r@ name>string icompare if
    r> drop 0 true 
  else
    2drop r> 0
  then ;

\ the analogon to search-wordlist
: search-name ( addr len wid -- nt | 0 )
  >r 0 ['] isword? r> traverse-wordlist
  dup 0= if
   2drop drop 0
  then
;

\ a magic number, check LST file for
\ the actual value!
$48 constant EE_ORDERLISTLEN

\ could be a quotation too
: (rec:name)
   >r 2dup r>
   search-name ( addr len wid -- nt | 0)
   dup if
    >r nip nip r> -1
   then
;

\ the parsing word
: rec:name ( addr len -- nt r:name | r:fail)
    ['] (rec:name)
    EE_ORDERLISTLEN
    map-stack
    0= if 2drop 0 then
;

\ replace rec:word with rec:name
\ everthing else should work as before
