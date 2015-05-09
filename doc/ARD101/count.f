\ count.f to Demo 7-segment LED control      DaR 2014-04-08
\ Define LED segment port bits and segment order
CREATE LEDS   7 2* 1 + allot \ Number of segments, then order
: \LEDS ( --- Initialize the RAM array )   7 LEDS C!
   LEDS count 2* PortD fill \ Overfill the Port addresses to save code
   2 LEDS 1 + C!  3 LEDS 3 + C!  4 LEDS 5 + C!  5 LEDS 7 + C!
   6 LEDS 9 + C!  7 LEDS 11 + C!  0 LEDS 13 + C!
   PortB LEDS 14 + C! ; \ Last segment on PortB
CREATE SEGS \ Try flash based array on SwiftX
   0 c, 0 c, 0 c, 0 c, 0 c, 0 c, 1 c, \ = 0
   1 c, 0 c, 0 c, 1 c, 1 c, 1 c, 1 c, \ = 1
   0 c, 0 c, 1 c, 0 c, 0 c, 1 c, 0 c, \ = 2
   0 c, 0 c, 0 c, 0 c, 1 c, 1 c, 0 c, \ = 3
   1 c, 0 c, 0 c, 1 c, 1 c, 0 c, 0 c, \ = 4
   0 c, 1 c, 0 c, 0 c, 1 c, 0 c, 0 c, \ = 5
   0 c, 1 c, 0 c, 0 c, 0 c, 0 c, 0 c, \ = 6
   0 c, 0 c, 0 c, 1 c, 1 c, 1 c, 1 c, \ = 7
   0 c, 0 c, 0 c, 0 c, 0 c, 0 c, 0 c, \ = 8
   0 c, 0 c, 0 c, 1 c, 1 c, 0 c, 0 c, \ = 9
: sevenSegWrite ( digit --- turn on the segments for the given digit )
   LEDS count  rot over * SEGS +  -rot 0 do
      swap count >r  swap count >r count r>  r> if
         PoBiHi  else  PoBiLo
      then
   loop  2drop ;
: counts ( time cycles --- produce cycles of digits )   \LEDS
   LEDS count 0 do  count >r count r> PoBiOut  loop  drop
   0 do  10 dup 0 do  dup i - 1- sevenSegWrite  over ms
   loop  drop  loop  drop ;
