\ game.f Digital Input and Output Game      DaR 2014-03-29
variable delayValue
: game ( --- cycles LEDs and check button presses )   \LEDS
   LEDS count 0 do  count >r count r> PoBiOut  loop  drop
   PortB buttonPin PoBiIn  200 delayValue !
   begin  LEDS count 0 do  count >r count r>
         2dup delayValue @ rot rot cycle
         PortB buttonPin PoBiRead 0 = if
            rot dup LEDS count 1 - 2* + = if
               delayValue @ 20 - dup 0 = if
                  ." You win!" 2drop drop exit
               then  delayValue !
            then  rot rot
            2dup 200 rot rot cycle
            2dup 200 rot rot cycle
         then  2drop
      loop  drop
   again ;
