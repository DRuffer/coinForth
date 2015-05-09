\ cycle.f to Demo multiple LED control      DaR 2014-03-29
\ Define LED port bits and flashing order
CREATE LEDS   4 2* 1 + allot \ Number of LEDS, then order
: \LEDS ( --- Initialize the RAM array )   4 LEDS C!
   LEDS count 2* PortD fill \ Overfill the Port addresses to save code
   2 LEDS 1 + C!  3 LEDS 3 + C!  4 LEDS 5 + C!  5 LEDS 7 + C! ;
: cycle ( time port bit --- flash LED on then off )
   2dup PoBiHi  rot dup ms  rot rot PoBiLo  ms ;
: cycles ( time cycles --- produce cycles of LED flashes )   \LEDS
   LEDS count 0 do  count >r count r> PoBiOut  loop  drop
   0 do  LEDS count 0 do  count >r count >r over r> r>
         cycle  loop  drop  loop  drop ;
