\ for/next is from colorforth
\ note that 0 and -1 are executable words, not numbers!
\
: for postpone 0
      postpone swap 
      postpone do
; immediate

: next
      postpone -1
      postpone +loop
; immediate

\ test case
\ : test 10 for i . next ;
\ prints
\ 10 9 8 7 6 5 4 3 2 1 0
\