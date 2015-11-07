\ the following code works in the AVR only

\ use the eeprom to keep the XT. Unlike the RAM/USER
\ based locations, the EEPROM vector is available without
\ initialization.
: Edefer ( "name" -- )
    (defer)
    ehere dup ,
    ['] Edefer@ ,
    ['] Edefer! ,
    cell+ to ehere
;

\ the flash is writable, not that often, but it is
: Idefer ( "name" -- )
    (defer)
    ['] noop , \ a dummy action as place holder
    [: @i execute ;] , \ XT is directly in the dictionary.
    [: !i ;] ,
;
