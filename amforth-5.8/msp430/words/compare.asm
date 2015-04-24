
HEADER(XT_COMPARE,7,"compare",DOCOLON)

; : compare ( c-addr1 len1 c-addr2 len 2 -- f )
;   f == 0 if both strings are equal
;   f <> 0 if strings differ, details are way more complex
;    rot over <> if ( -- c-addr1 c-addr2 len2)
;     \ string dont have the same length
;     drop drop drop -1 exit then
;   s= ;

    DW XT_ROT,XT_OVER,XT_NOTEQUAL
    DW XT_DOCONDBRANCH
    DEST(COMPARE_1)
	DW XT_DROP,XT_2DROP, XT_MINUSONE,XT_EXIT
COMPARE_1:
    DW XT_SEQUAL
    DW XT_EXIT
