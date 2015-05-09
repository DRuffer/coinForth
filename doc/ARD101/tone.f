\ Audio tone generator                      30Mar14
\ Modified for 328eForth, 23mar11cht
\ Modified for SwiftX by daruffer@gmail.com

\ Must have io-core.f installed

6 value Tone-out \ PortD bit 6

binary

: setup-osc \ prescale limit  ---  limit 1..255, prescale 1..5
   PortD   Tone-out                  PoBiOut \ setup output pin    
   OCR0A   true      rot ( limit   ) RegTo
   TCCR0A  11000011  01000010        RegTo   \ CTC mode
           00000101  min    0  max    \ form TCCR0B prescale
   TCCR0B  00001111 rot ( prescale ) RegTo ;  \ and tone on  

: tone-off \  ---  end output tone setting prescale to zeros
   TCCR0B  00000111  false RegTo ;

decimal

78 value Limit   4 value Prescale  \ 400 Hz tone parameters

: ud/mod ( ud1 n -- rem ud2 ) >R 0 R@ UM/MOD R> SWAP >R UM/MOD R> ;
: Hertz   \ frequency --- load Limit and Prescale 
   $1200 $7A ( 8000000. ) rot ud/mod  \ total scale as rem double-quot
   dup            if ( >16 bits)  1024  5 else 
   over $C000 and if ( >14 bits)   256  4 else 
   over $F800 and if ( >10 bits)    64  3 else 
   over $FF00 and if ( > 8 bits)     8  2 else   1  1  
                     then then then then  
   to Prescale   um/mod to Limit  drop drop ( two remainders ) ;

: tone-on   \ ---  begin tone from fixed presets
    Prescale  Limit  setup-osc ;

: note  \ duration ---    generate timed tone for duration msec.
    tone-on  ms  tone-off ;

\ End of tone.f
