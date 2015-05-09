\ volts.f to Demo Analog input      DaR 2014-03-29
 0 value analogPin \ Use analog pin 0 for the voltage pin
: volts ( --- read state of pot )
   PortC analogPin PoBiInPu
   $40 ADMux c!  $c3 ADCSra c!  ADCL @
   cr ." The voltage is "  500 1023 */
   0 <# # # $2e hold # #> type space ;
