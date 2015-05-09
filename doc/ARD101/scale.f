\ Play musical scale                      13Apr14

CREATE scale \ sequence of notes, pauses and times
   1047 , 500 , 0 , 500 , 1175 , 500 , 0 , 500 ,
   1319 , 500 , 0 , 500 , 1397 , 500 , 0 , 500 ,
   1568 , 500 , 0 , 500 , 1760 , 500 , 0 , 500 ,
   1976 , 500 , 0 , 500 , 2093 , 500 , 0 , 500 ,
      0 ,   0 ,  \ Null terminators

: notes ( a -- ) \ Play sequence of notes, pauses and times
   begin  dup 2@  2dup or while  ?dup if
         Hertz note  else  ms
      then  2 cells +
   repeat  drop ;
