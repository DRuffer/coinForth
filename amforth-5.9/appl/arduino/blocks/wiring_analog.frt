\ analog read functions for arduino.
\ 
\ usage
\  once (in turnkey): adc.init (sets up the subsystem)
\  repeated: analog.X analog_read ( -- n)
\  

\ \\\\\\\\\\\\\\\\\\\\\\\\\\\
\      HELPER ROUTINES      \
\ \\\\\\\\\\\\\\\\\\\\\\\\\\\
\ pin>channel
\     convert bitmask of portpin: back to value (bitposition)
: pin>channel   ( pinmask portaddr -- pos )
  drop          ( -- pinmask )
  log2          ( -- pos_of_most_significant_bit )
;

: adc.init ( -- )
  \ ADMUX
  \ A_ref is NOT connected externally
  \ ==> need to set bit REFS0 in register ADMUX
  [ 0 5 lshift      \ ADLAR off, makes read operation simpler
    1 6 lshift or   \ REFS0
  ] literal ADMUX c!
  \ ADCSRA
  [ 1 7 lshift      \ ADEN   ADC enabled
    1 2 lshift or   \ ADPS2  prescaler = 128
    1 1 lshift or   \ ADPS1  .
    1          or   \ ADPS0  .
  ] literal ADCSRA c!
;
: adc.init.pin ( bitmask portaddr -- )
  over over high
  pin_input
;
  
1 6 lshift constant ADSC_MSK \ ADStartConversion bitmask
: adc.start
  \ start conversion
  ADSC_MSK ADCSRA high
;
: adc.wait
  \ wait for completion of conversion
  begin
    ADCSRA c@ ADSC_MSK and 0=
  until
;
: adc.channel! ( channel -- )
  7 and                 \ clip channel to 0..7
  ADMUX c@ 7 invert and \ read ADMUX, clear old channel
  or                    \ add new channel
  ADMUX c!              \ write
;

: adc.get ( namedpin -- a )
  pin>channel adc.channel! adc.start adc.wait
  ADC @ \ always 10bit
;

\ make sure the ports are set up and do one
\ conversion.
: analog_read ( pinmask portaddr -- n )
     2dup adc.init.pin
     adc.get
;
