\ Sierpinski fractal
\ richard.w@gmail.com, clf 13.2.2015

\ additional words from the forth lib
\ #require buffer.frt
\ #require blank.frt
\ #require chars.frt

64 constant size
char * constant '*'
size buffer: line[]

line[] size blank   '*' size 2/ chars line[] + c!  ( init )

: .line[] ( -- ) line[] size type cr ;
: =*? ( addr -- f ) c@   '*' = ;
: >char ( f f -- ch ) xor [ '*' bl - ] literal and bl + ;
: init-flags ( -- f-1 f0 )  0  line[] =*? ;
: sierp-line ( -- ) init-flags   line[] size bounds do
       i 1 chars + =*?   rot over >char   i c!
   loop 2drop ;
: sierpinski ( -- ) size 2/ 0 do .line[] sierp-line loop ;

\
\ sierpinski prints the fractal on the terminal
\