;Z ITYPE   c-addr +n --       type line to term'l
;   ?DUP IF                       from Code space
;     OVER + XT_SWAP DO I IC@ EMIT LOOP
;   ELSE DROP THEN ;
    HEADER(XT_ITYPE,5,"itype",DOCOLON)
    DW XT_TYPE,XT_EXIT
