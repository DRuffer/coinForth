;Z NFA>CFA   nfa -- cfa    name adr -> code field
;   HCOUNT 7F AND + ALIGNED ;   mask off 'smudge' bit
    HEADER(XT_NFA2CFA,7,"nfa>cfa",DOCOLON)
        DW XT_ICOUNT
        DW XT_DOLITERAL,07Fh,XT_AND,XT_PLUS,XT_ALIGNED,XT_EXIT
