;X tib     -- a-addr     Terminal Input Buffer
;  HEX 80 USER TIB       8086: above user area
    HEADER(TIB,3,"tib",DOUSER)
        DW TIBAREA-UAREA
