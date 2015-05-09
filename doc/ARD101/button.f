\ button.f to Demo Digital input      DaR 2014-03-29
4 value buttonPin \ Use digital pin 12 for the button pin
: states ( --- read state of button )
   PortB buttonPin 2dup PoBiIn  PoBiRead
   begin  PortB buttonPin PoBiRead
      2dup = while  nip  repeat
   cr ." The button state is " . drop ;
