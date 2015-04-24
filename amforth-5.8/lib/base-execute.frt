\ execute xt with the content of BASE being u, and
\ restoring the original BASE afterwards.
: base-execute ( i*x xt u -- j*x ) \ gforth
    base @ >r
    base ! execute 
    r> base !
;