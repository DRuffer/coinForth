;Z I->D     c-addr1 c-addr2 u --  move Code->Data
; Block move from Code space to Data space.
; On the MSP430, this is the same as CMOVE.
       HEADER(XT_ITOD,4,"i->d",XT_CMOVE+2)
