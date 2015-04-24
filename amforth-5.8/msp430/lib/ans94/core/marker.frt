
;X MARKER   --      create word to restore dictionary
;   LATEST @ XT_IHERE HERE
;   XT_IHERE FLALIGNED IDP !     align new word to flash boundary
;   <BUILDS I, I, I,        save dp,idp,latest
;   DOES>  DUP I@  
;   XT_SWAP CELL+ DUP I@
;   XT_SWAP CELL+ I@           fetch saved   -- dp idp latest 
;   OVER FLALIGNED XT_IHERE OVER - FLERASE    erase Flash from saved to XT_IHERE
;   LATEST ! IDP ! DP ! ;

: marker
    latest @ ihere here ihere flaligned idp !
    <builds
      , , , 
    does>
      dup @i 
      swap cell+ dup @i 
      swap cell+ @i 
      over flaligned ihere over - flerase
      latest ! idp ! dp !
;
