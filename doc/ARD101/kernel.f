\ Files included by build.f

INCLUDE %SwiftX/src/avr/code/config             \ Common configuration
INCLUDE config                                  \ Target configuration
INCLUDE %SwiftX/src/avr/reg_m328p               \ ATmega328P register definitions
INCLUDE %SwiftX/src/avr/code/int                \ Interrupt vectors **load before any CODE words**
INCLUDE %SwiftX/src/avr/code/core               \ Core word set
INCLUDE %SwiftX/src/avr/code/user               \ User variables
INCLUDE %SwiftX/src/core                        \ Common core words
INCLUDE %SwiftX/src/avr/code/extra              \ Miscellaneous extensions
INCLUDE %SwiftX/src/avr/code/math               \ Core math operators
INCLUDE %SwiftX/src/avr/code/string             \ Core string operators
INCLUDE %SwiftX/src/string                      \ Core string operators
INCLUDE %SwiftX/src/avr/code/opt                \ Optimizer rules
INCLUDE %SwiftX/src/vio                         \ Vectored I/O functions
INCLUDE %SwiftX/src/avr/code/except             \ Exception handling
INCLUDE %SwiftX/src/except                      \ Common exception handling
INCLUDE %SwiftX/src/avr/code/double             \ Double-precision numbers
INCLUDE %SwiftX/src/double                      \ Double-precision numbers
INCLUDE %SwiftX/src/mixed                       \ Mixed-precision operators
INCLUDE %SwiftX/src/output                      \ Core and facility output functions
INCLUDE %SwiftX/src/output2                     \ Double output functions
INCLUDE %SwiftX/src/number                      \ Numeric input conversion functions
INCLUDE %SwiftX/src/methods                     \ Methods and VALUE
INCLUDE %SwiftX/src/avr/code/tasker             \ Multitasker
INCLUDE %SwiftX/src/tools                       \ Debug tools
INCLUDE %SwiftX/src/dump1                       \ Memory dump
INCLUDE %SwiftX/src/xtlctrl                     \ XTL support
INCLUDE %SwiftX/src/avr/code/serial             \ Internal UART cross-target link
INCLUDE %SwiftX/src/xtl                         \ Common serial XTL functions
INCLUDE %SwiftX/src/avr/code/stepper            \ Single-step debug support
INCLUDE %SwiftX/src/avr/code/timer0             \ Timer functions
INCLUDE %SwiftX/src/timing                      \ Common timing functions
INCLUDE %SwiftX/src/avr/code/eeprom             \ Internal EEPROM access
INCLUDE %SwiftX/src/accept                      \ Generic terminal input
INCLUDE %SwiftX/src/avr/code/terminal           \ Polled serial terminal
TARGET-INTERP [IF]
INCLUDE %Swiftx/src/avr/code/interp             \ Resident interpreter support
INCLUDE %Swiftx/src/interp                      \ Resident interpreter
INCLUDE %Swiftx/src/mem                         \ Resident memory management
INCLUDE %Swiftx/src/quit                        \ Interpreter loop
[THEN]
INCLUDE app                                     \ **YOUR APPLICATION LOADED BY THIS FILE**
INCLUDE %SwiftX/src/avr/code/start              \ Common power-up
INCLUDE start                                   \ Power-up
