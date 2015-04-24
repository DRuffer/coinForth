; ( addr len -- 0 | xt +/- 1 )
    HEADER(XT_FINDNAME,9,"find-name",DOCOLON)
    DW XT_LATEST
    DW XT_SEARCH_WORDLIST
    DW XT_EXIT
