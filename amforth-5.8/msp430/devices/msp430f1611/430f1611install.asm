; ----------------------------------------------------------------------
; CamelForth for the Texas Instruments MSP430 
; (c) 2013,2014 Bradford J. Rodriguez.
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;
; Commercial inquiries should be directed to the author at 
; 115 First St., #105, Collingwood, Ontario L9Y 4W3 Canada
; or via email to bj@camelforth.com
; ----------------------------------------------------------------------
; 430f1611install.asm - 
; Interrupt handler installation for MSP430F1611
; B. Rodriguez 20 aug 2013
; ----------------------------------------------------------------------
; REVISION HISTORY
;  2 mar 2014 bjr - adapted from install430g2553.s43 for naken_asm.
; 25 dec 2013 bjr - Created for 'F1611.

; This installs an interrupt handler address in a jump table
; in a 64-byte region of RAM.  
; The vector is installed as a MOV #adrs,PC instruction.

; Example: 3 INSTALL TIMERIRPT
; installs the body of the word TIMERIRPT as interrupt vector #3.
; Note that vector numbering varies among members of the MSP430
; family.

; Vectors should be INSTALLed at compile time, and the RAM vector
; table saved with SAVE.  A coldstart will clear the RAM vector
; table.

; DECIMAL 60 CONSTANT VECSSIZE ( only 60 bytes are used )
;   ...defined as VECS_SIZE = 30 (cells) in camel430f1611.asm
; HEX ???? CONSTANT VECAREA    ( 64 bytes for 'F1611 )
;   ...defined in camel430f1611.asm

;Z INSTALL   n -- | "word" 
; : INSTALL ( n -- | "word" )
;     '               ( CFA of interrupt handler )
;     >BODY           ( address of interrupt handler ( -- n pfa )
;     SWAP 2* CELLS VECAREA +    ( -- pfa vecadr )
;     4030 OVER !     ( MOV #,PC instruction )
;     CELL+ !         ( store address of interrupt handler )
; ;

    HEADER(INSTALL,7,"INSTALL",DOCOLON)
        DW  TICK,TOBODY
        DW  SWAP,TWOSTAR,CELLS,lit,VECAREA,PLUS
        DW  lit,4030h,OVER,STORE
        DW  CELLPLUS,STORE
        DW  EXIT
