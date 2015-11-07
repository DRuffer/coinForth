\ #require count.frt

: find ( addr --  addr 0 | xt -1 | xt 1 ) 
  dup count find-name  dup
  if rot drop then
;

\ \ find-name is using the order stack
\ \ with map-stack as iterator.
\ : (find) 
\     >r 2dup r> search-wordlist 
\     dup if
\       >r nip nip r> -1 
\     then 
\ ;
\ 
\ : find-name 
\    ['] (find) 'ORDER map-stack
\    0= if 2drop 0 then 
\ ;

